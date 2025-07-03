// lib/domain/entities/project.dart

import 'package:minha_aplicacao_flutter/domain/entities/user.dart';

class Project {
  final String id;
  final String name;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<User>? assignedUsers; // Para associação N:N

  Project({
    required this.id,
    required this.name,
    required this.description,
    this.startDate,
    this.endDate,
    this.assignedUsers,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Project && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
