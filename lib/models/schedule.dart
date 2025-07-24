import 'package:flutter/material.dart';

class Schedule {
  int? id;
  String name;
  TimeOfDay startTime;
  TimeOfDay endTime;
  int dayOfWeek;
  String? room;
  String? teacher;
  Color color;
  String? notes;

  Schedule({
    this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.dayOfWeek,
    this.room,
    this.teacher,
    this.color = Colors.blue,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'startTimeHour': startTime.hour,
      'startTimeMinute': startTime.minute,
      'endTimeHour': endTime.hour,
      'endTimeMinute': endTime.minute,
      'dayOfWeek': dayOfWeek,
      'room': room,
      'teacher': teacher,
      'colorValue': color.value,
      'notes': notes,
    };
  }

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'],
      name: map['name'],
      startTime: TimeOfDay(hour: map['startTimeHour'], minute: map['startTimeMinute']),
      endTime: TimeOfDay(hour: map['endTimeHour'], minute: map['endTimeMinute']),
      dayOfWeek: map['dayOfWeek'],
      room: map['room'],
      teacher: map['teacher'],
      color: Color(map['colorValue']),
      notes: map['notes'],
    );
  }
}