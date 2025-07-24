import 'package:flutter/material.dart';
import 'package:my_class_schedule/models/schedule.dart';
import 'package:my_class_schedule/database/database_helper.dart';

class ScheduleProvider with ChangeNotifier {
  List<Schedule> _schedules = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Schedule> get schedules => _schedules;

  ScheduleProvider() {
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    _schedules = await _dbHelper.getSchedules();
    notifyListeners();
  }

  Future<void> addSchedule(Schedule schedule) async {
    await _dbHelper.insertSchedule(schedule);
    await _loadSchedules();
  }

  Future<void> updateSchedule(Schedule schedule) async {
    await _dbHelper.updateSchedule(schedule);
    await _loadSchedules();
  }

  Future<void> deleteSchedule(int id) async {
    await _dbHelper.deleteSchedule(id);
    await _loadSchedules();
  }

  List<Schedule> getSchedulesForDay(int dayOfWeek) {
    return _schedules.where((s) => s.dayOfWeek == dayOfWeek).toList()
      ..sort((a, b) => a.startTime.hour * 60 + a.startTime.minute - (b.startTime.hour * 60 + b.startTime.minute));
  }
}