// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScheduleAdapter extends TypeAdapter<Schedule> {
  @override
  final int typeId = 0;

  @override
  Schedule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Schedule(
      id: fields[0] as int?,
      name: fields[1] as String,
      dayOfWeek: fields[2] as int,
      startTime: fields[3] as TimeOfDay,
      endTime: fields[4] as TimeOfDay,
      color: fields[5] as Color,
      notes: fields[6] as String?,
      professorId: fields[7] as int?,
      roomId: fields[8] as int?,
      topicIds: (fields[9] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, Schedule obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.dayOfWeek)
      ..writeByte(3)
      ..write(obj.startTime)
      ..writeByte(4)
      ..write(obj.endTime)
      ..writeByte(5)
      ..write(obj.color)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.professorId)
      ..writeByte(8)
      ..write(obj.roomId)
      ..writeByte(9)
      ..write(obj.topicIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
