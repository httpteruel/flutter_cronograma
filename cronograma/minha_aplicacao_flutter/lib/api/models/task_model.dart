// lib/api/models/task_model.dart

import 'package:minha_aplicacao_flutter/domain/entities/task.dart';
import 'package:minha_aplicacao_flutter/api/models/project_model.dart'; // Para associação 1:N
import 'package:minha_aplicacao_flutter/api/models/user_model.dart'; // Para o usuário atribuído

class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String status; // String para corresponder à API
  final String projectId;
  final ProjectModel? project; // Opcional, para incluir os dados do projeto
  final UserModel? assignedUser; // Opcional, para o usuário atribuído

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.projectId,
    this.project,
    this.assignedUser,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      status: json['status'] as String,
      projectId: json['projectId'] as String,
      project: json['project'] != null
          ? ProjectModel.fromJson(json['project'] as Map<String, dynamic>)
          : null,
      assignedUser: json['assignedUser'] != null
          ? UserModel.fromJson(json['assignedUser'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'status': status,
      'projectId': projectId,
      // project e assignedUser não são enviados no toJson em requisições de criação/atualização de tarefa.
      // Eles são geralmente incluídos em respostas de GET.
    };
  }

  Task toEntity() {
    return Task(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      status: TaskStatus.values.firstWhere(
        (e) => e.toString().split('.').last == status,
        orElse: () => TaskStatus.pending, // Default se não encontrar
      ),
      projectId: projectId,
      project: project?.toEntity(),
      assignedUser: assignedUser?.toEntity(),
    );
  }

  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      status:
          task.status.toString().split('.').last, // Converte enum para string
      projectId: task.projectId,
      project:
          task.project != null ? ProjectModel.fromEntity(task.project!) : null,
      assignedUser: task.assignedUser != null
          ? UserModel.fromEntity(task.assignedUser!)
          : null,
    );
  }
}
