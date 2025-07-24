import 'package:hive/hive.dart';

part 'professor.g.dart';

@HiveType(typeId: 1)
class Professor extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? email;

  @HiveField(3)
  String? phone;

  Professor({
    this.id,
    required this.name,
    this.email,
    this.phone,
  });

  // --- ADICIONE ESTE MÉTODO copyWith ---
  Professor copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
  }) {
    return Professor(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
  // ------------------------------------
}