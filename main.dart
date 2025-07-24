import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importações de Models
import 'package:my_class_schedule/models/schedule.dart';
import 'package:my_class_schedule/models/professor.dart';
import 'package:my_class_schedule/models/room.dart';
import 'package:my_class_schedule/models/topic.dart';
import 'package:my_class_schedule/models/subject.dart'; // Importa o modelo Subject
import 'package:my_class_schedule/models/hive_adapters.dart'; // Contém TimeOfDayAdapter e ColorAdapter

// Importações de Providers
import 'package:my_class_schedule/providers/schedule_provider.dart';
import 'package:my_class_schedule/providers/professor_provider.dart';
import 'package:my_class_schedule/providers/room_provider.dart';
import 'package:my_class_schedule/providers/topic_provider.dart';
import 'package:my_class_schedule/providers/subject_provider.dart'; // Importa o SubjectProvider
import 'package:my_class_schedule/providers/announcement_provider.dart'; // NOVO: Importa o AnnouncementProvider

// Importações de Telas
import 'package:my_class_schedule/screens/home_screen.dart';

// Importações de Hive
import 'package:hive_flutter/hive_flutter.dart';

// Importações para Notificações Locais
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicializa o Hive
  await Hive.initFlutter();

  // 2. Registra os TypeAdapters para seus modelos personalizados e os adaptadores de utilidade
  // Certifique-se de que os typeIds são únicos!
  Hive.registerAdapter(ScheduleAdapter());      // typeId: 0
  Hive.registerAdapter(TimeOfDayAdapter());    // typeId: 1
  Hive.registerAdapter(ColorAdapter());        // typeId: 2
  Hive.registerAdapter(ProfessorAdapter());    // typeId: 3
  Hive.registerAdapter(RoomAdapter());         // typeId: 4
  Hive.registerAdapter(TopicAdapter());        // typeId: 5
  Hive.registerAdapter(SubjectAdapter());      // typeId: 6 (verifique se este é o mesmo do seu subject.dart)


  // 3. Inicializa e configura as notificações locais
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await _configureLocalNotifications(flutterLocalNotificationsPlugin);


  // 4. Executa o aplicativo com MultiProvider para gerenciar estados
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ScheduleProvider(flutterLocalNotificationsPlugin)),
        ChangeNotifierProvider(create: (context) => ProfessorProvider()),
        ChangeNotifierProvider(create: (context) => RoomProvider()),
        ChangeNotifierProvider(create: (context) => TopicProvider()),
        ChangeNotifierProvider(create: (context) => SubjectProvider()),
        ChangeNotifierProvider(create: (context) => AnnouncementProvider()), // NOVO: Adiciona o AnnouncementProvider
      ],
      child: MyApp(),
    ),
  );
}

// Função para configurar as notificações locais
Future<void> _configureLocalNotifications(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon'); // Verifique se 'app_icon' está no seu drawable

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.payload != null) {
        debugPrint('notification payload: ${response.payload}');
        // Você pode adicionar lógica aqui para lidar com a resposta da notificação (ex: navegar para uma tela específica)
      }
    },
  );

  // Configuração do fuso horário para notificações agendadas
  tz.initializeTimeZones();
  try {
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  } catch (e) {
    print('Erro ao obter o fuso horário local: $e');
    tz.setLocalLocation(tz.getLocation('UTC')); // Fallback para UTC se houver erro
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu Cronograma de Aulas',
      debugShowCheckedModeBanner: false, // Oculta o banner de debug
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.deepPurpleAccent,
          foregroundColor: Colors.white,
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
      home: HomeScreen(), // Tela inicial do aplicativo
    );
  }
}