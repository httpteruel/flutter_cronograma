// lib/api/models/project_model.dart

import 'package:minha_aplicacao_flutter/domain/entities/project.dart';
import 'package:minha_aplicacao_flutter/api/models/user_model.dart'; // Importar UserModel para associação N:N

class ProjectModel {
  final String id;
  final String name;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<UserModel>? assignedUsers; // Para associação N:N

  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    this.startDate,
    this.endDate,
    this.assignedUsers,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      assignedUsers: (json['assignedUsers'] as List<dynamic>?)
          ?.map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'assignedUsers': assignedUsers?.map((e) => e.toJson()).toList(),
    };
  }

  Project toEntity() {
    return Project(
      id: id,
      name: name,
      description: description,
      startDate: startDate,
      endDate: endDate,
      assignedUsers: assignedUsers?.map((e) => e.toEntity()).toList(),
    );
  }

  factory ProjectModel.fromEntity(Project project) {
    return ProjectModel(
      id: project.id,
      name: project.name,
      description: project.description,
      startDate: project.startDate,
      endDate: project.endDate,
      assignedUsers:
          project.assignedUsers?.map((e) => UserModel.fromEntity(e)).toList(),
    );
  }
}
