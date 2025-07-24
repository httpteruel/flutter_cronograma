import 'package:hive/hive.dart';

part 'topic.g.dart'; // Gerado automaticamente pelo build_runner

@HiveType(typeId: 5)
class Topic extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3) // <<< NOVO CAMPO: Lista de IDs das matérias associadas
  List<int> subjectIds;

  Topic({
    this.id,
    required this.name,
    this.description,
    this.subjectIds = const [], // Inicializa como lista vazia por padrão
  });

  // Método copyWith para facilitar a atualização
  Topic copyWith({
    int? id,
    String? name,
    String? description,
    List<int>? subjectIds, // <<< NOVO NO copyWith
  }) {
    return Topic(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      subjectIds: subjectIds ?? this.subjectIds, // <<< NOVO NO copyWith
    );
  }
}