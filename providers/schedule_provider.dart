import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_class_schedule/models/schedule.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart'; // <<< Adicionei este import aqui também para garantir.

// Importe os modelos Professor e Room para acessar os dados no Hive para a notificação
import 'package:my_class_schedule/models/professor.dart';
import 'package:my_class_schedule/models/room.dart';

class ScheduleProvider with ChangeNotifier {
  late Box<Schedule> _scheduleBox;
  List<Schedule> _schedules = [];

  final FlutterLocalNotificationsPlugin _notificationsPlugin; // Declaração do plugin

  List<Schedule> get schedules => _schedules;

  ScheduleProvider(this._notificationsPlugin) { // Construtor que recebe o plugin
    _initHiveAndLoadSchedules();
  }

  Future<void> _initHiveAndLoadSchedules() async {
    _scheduleBox = await Hive.openBox<Schedule>('schedules');
    _loadSchedules();
  }

  void _loadSchedules() {
    _schedules = _scheduleBox.values.toList();
    _schedules.sort((a, b) {
      if (a.dayOfWeek != b.dayOfWeek) {
        return a.dayOfWeek.compareTo(b.dayOfWeek);
      }
      return _compareTimeOfDay(a.startTime, b.startTime);
    });
    notifyListeners();
  }

  int _compareTimeOfDay(TimeOfDay t1, TimeOfDay t2) {
    if (t1.hour != t2.hour) {
      return t1.hour.compareTo(t2.hour);
    }
    return t1.minute.compareTo(t2.minute);
  }

  // --- MÉTODOS DE MANIPULAÇÃO DE AGENDAMENTOS ---

  Future<void> addSchedule(Schedule schedule) async {
    if (schedule.id == null) {
      schedule.id = await _scheduleBox.add(schedule);
    } else {
      await _scheduleBox.put(schedule.id!, schedule);
    }
    _loadSchedules();
    await _scheduleNotification(schedule); // Chama a função de notificação
  }

  Future<void> updateSchedule(Schedule schedule) async {
    await _scheduleBox.put(schedule.id!, schedule);
    _loadSchedules();
    await _scheduleNotification(schedule); // Re-agenda a notificação
  }

  Future<void> deleteSchedule(int id) async {
    await _scheduleBox.delete(id);
    _loadSchedules();
    await _cancelNotification(id); // Cancela a notificação
  }

  List<Schedule> getSchedulesForDay(int dayOfWeek) {
    return _schedules
        .where((schedule) => schedule.dayOfWeek == dayOfWeek)
        .toList();
  }

  List<Schedule> getFilteredAndSortedSchedules({
    int? dayOfWeek,
    int? professorId,
    int? roomId,
    String sortBy = 'day_asc',
  }) {
    List<Schedule> results = List.from(_schedules);

    if (dayOfWeek != null) {
      results = results.where((s) => s.dayOfWeek == dayOfWeek).toList();
    }
    if (professorId != null) {
      results = results.where((s) => s.professorId == professorId).toList();
    }
    if (roomId != null) {
      results = results.where((s) => s.roomId == roomId).toList();
    }

    results.sort((a, b) {
      switch (sortBy) {
        case 'name_asc':
          return a.name.compareTo(b.name);
        case 'name_desc':
          return b.name.compareTo(a.name);
        case 'time_asc':
          int compare = _compareTimeOfDay(a.startTime, b.startTime);
          if (compare != 0) return compare;
          return a.name.compareTo(b.name);
        case 'time_desc':
          int compare = _compareTimeOfDay(b.startTime, a.startTime);
          if (compare != 0) return compare;
          return b.name.compareTo(a.name);
        case 'day_asc':
        default:
          if (a.dayOfWeek != b.dayOfWeek) {
            return a.dayOfWeek.compareTo(b.dayOfWeek);
          }
          int timeCompare = _compareTimeOfDay(a.startTime, b.startTime);
          if (timeCompare != 0) return timeCompare;
          return a.name.compareTo(b.name);
      }
    });

    return results;
  }

  // --- MÉTODOS DE NOTIFICAÇÃO (VERIFIQUE SE ESTÃO DENTRO DESTA CLASSE ScheduleProvider) ---

  Future<void> _scheduleNotification(Schedule schedule) async {
    if (schedule.id != null) {
      await _notificationsPlugin.cancel(schedule.id!);
    }

    final now = tz.TZDateTime.now(tz.local);

    final int daysUntilNextOccurrence = (schedule.dayOfWeek - now.weekday + 7) % 7;

    final DateTime targetDate = DateTime(
      now.year,
      now.month,
      now.day + daysUntilNextOccurrence,
      schedule.startTime.hour,
      schedule.startTime.minute,
    );

    final tz.TZDateTime scheduledTZDateTime = tz.TZDateTime.from(targetDate, tz.local);

    final tz.TZDateTime notificationTime = scheduledTZDateTime.subtract(Duration(minutes: 15));

    if (notificationTime.isBefore(now)) {
        final nextWeekNotificationTime = notificationTime.add(Duration(days: 7));
        if (nextWeekNotificationTime.isAfter(now)) {
            _scheduleRepeatingNotification(schedule, nextWeekNotificationTime);
        } else {
            print('Aviso: Notificação para ${schedule.name} para a próxima semana ainda estaria no passado. Não agendada.');
        }
    } else {
        _scheduleRepeatingNotification(schedule, notificationTime);
    }
  }

  Future<void> _scheduleRepeatingNotification(Schedule schedule, tz.TZDateTime notificationTime) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'schedule_channel',
      'Lembretes de Aulas',
      channelDescription: 'Notificações para lembrar sobre as aulas agendadas.',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

    // Abrindo as boxes do Hive diretamente para buscar professor e sala para a notificação
    // Isso evita ter que passar ProfessorProvider e RoomProvider para o ScheduleProvider.
    final professorBox = await Hive.openBox<Professor>('professors');
    final roomBox = await Hive.openBox<Room>('rooms');

    final Professor? professor = professorBox.get(schedule.professorId);
    final Room? room = roomBox.get(schedule.roomId);

    final String professorName = professor?.name ?? 'Professor Desconhecido';
    final String roomName = room?.name ?? 'Sala Desconhecida';


    await _notificationsPlugin.zonedSchedule(
      schedule.id!,
      'Lembrete: Sua Aula de ${schedule.name} está chegando!',
      'Começa em 15 minutos com $professorName na sala $roomName.',
      notificationTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: 'schedule_id:${schedule.id}',
    );
    print('Notificação agendada para ${schedule.name} em $notificationTime');

    // Feche as boxes após o uso para liberar recursos, se não forem mantidas abertas.
    // Se você estiver abrindo e fechando estas boxes em vários lugares,
    // considere ter um serviço de banco de dados para gerenciar o ciclo de vida das boxes.
    // Para esta função específica, fechá-las após o uso é seguro.
    await professorBox.close();
    await roomBox.close();
  }

  Future<void> _cancelNotification(int scheduleId) async {
    await _notificationsPlugin.cancel(scheduleId);
    print('Notificação cancelada para o agendamento ID: $scheduleId');
  }
}