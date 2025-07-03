// lib/domain/entities/task.dart

import 'package:minha_aplicacao_flutter/domain/entities/user.dart';
import 'package:minha_aplicacao_flutter/domain/entities/project.dart';

enum TaskStatus {
  pending,
  inProgress,
  completed,
  deferred,
}

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskStatus status;
  final String projectId; // Para associação 1:N com Project
  final Project? project; // Opcional, para incluir os dados do projeto
  final User? assignedUser; // Opcional, para o usuário atribuído

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.status = TaskStatus.pending,
    required this.projectId,
    this.project,
    this.assignedUser,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskStatus? status,
    String? projectId,
    Project? project,
    User? assignedUser,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      projectId: projectId ?? this.projectId,
      project: project ?? this.project,
      assignedUser: assignedUser ?? this.assignedUser,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
