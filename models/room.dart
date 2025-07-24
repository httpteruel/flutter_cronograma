import 'package:hive/hive.dart';

part 'room.g.dart';

@HiveType(typeId: 2)
class Room extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int? capacity;

  @HiveField(3)
  String? location;

  Room({
    this.id,
    required this.name,
    this.capacity,
    this.location,
  });

  // --- ADICIONE ESTE MÉTODO copyWith ---
  Room copyWith({
    int? id,
    String? name,
    int? capacity,
    String? location,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      capacity: capacity ?? this.capacity,
      location: location ?? this.location,
    );
  }
  // ------------------------------------
}