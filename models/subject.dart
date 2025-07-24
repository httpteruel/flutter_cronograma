import 'package:hive/hive.dart';

part 'subject.g.dart'; // Gerado automaticamente pelo build_runner

@HiveType(typeId: 6) // <<< Importante: use um typeId único e não utilizado (0-5 já foram)
class Subject extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String name;

  Subject({
    this.id,
    required this.name,
  });

  // Método copyWith para facilitar a atualização
  Subject copyWith({
    int? id,
    String? name,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}