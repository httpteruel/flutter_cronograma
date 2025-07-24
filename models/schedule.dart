import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'schedule.g.dart';

@HiveType(typeId: 0)
class Schedule extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int dayOfWeek;

  @HiveField(3)
  TimeOfDay startTime;

  @HiveField(4)
  TimeOfDay endTime;

  @HiveField(5)
  Color color;

  @HiveField(6)
  String? notes;

  @HiveField(7)
  int? professorId;

  @HiveField(8)
  int? roomId;

  @HiveField(9) // <<< NOVO CAMPO: Lista de IDs dos tópicos associados
  List<int> topicIds; // Inicializa como lista vazia por padrão se nenhum for fornecido

  Schedule({
    this.id,
    required this.name,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.color,
    this.notes,
    this.professorId,
    this.roomId,
    this.topicIds = const [], // Garante que não seja nulo
  });

  // Método copyWith para facilitar a atualização (importante para as telas de edição)
  Schedule copyWith({
    int? id,
    String? name,
    int? dayOfWeek,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    Color? color,
    String? notes,
    int? professorId,
    int? roomId,
    List<int>? topicIds, // <<< NOVO NO copyWith
  }) {
    return Schedule(
      id: id ?? this.id,
      name: name ?? this.name,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      notes: notes ?? this.notes,
      professorId: professorId ?? this.professorId,
      roomId: roomId ?? this.roomId,
      topicIds: topicIds ?? this.topicIds, // <<< NOVO NO copyWith
    );
  }
}