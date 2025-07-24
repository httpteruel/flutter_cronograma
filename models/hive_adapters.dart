import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

// Adaptador para TimeOfDay
@HiveType(typeId: 3) // typeId único para TimeOfDay (usado apenas para este adaptador)
class TimeOfDayAdapter extends TypeAdapter<TimeOfDay> {
  @override
  final int typeId = 3; // O mesmo typeId da anotação @HiveType

  @override
  TimeOfDay read(BinaryReader reader) {
    final hour = reader.readInt();
    final minute = reader.readInt();
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  void write(BinaryWriter writer, TimeOfDay obj) {
    writer.writeInt(obj.hour);
    writer.writeInt(obj.minute);
  }
}

// Adaptador para Color
@HiveType(typeId: 4) // typeId único para Color (usado apenas para este adaptador)
class ColorAdapter extends TypeAdapter<Color> {
  @override
  final int typeId = 4; // O mesmo typeId da anotação @HiveType

  @override
  Color read(BinaryReader reader) {
    final value = reader.readInt();
    return Color(value);
  }

  @override
  void write(BinaryWriter writer, Color obj) {
    writer.writeInt(obj.value);
  }
}