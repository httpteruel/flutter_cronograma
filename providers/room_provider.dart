import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_class_schedule/models/room.dart';

class RoomProvider with ChangeNotifier {
  late Box<Room> _roomBox;
  List<Room> _rooms = [];

  List<Room> get rooms => _rooms;

  RoomProvider() {
    _initHiveAndLoadRooms();
  }

  Future<void> _initHiveAndLoadRooms() async {
    _roomBox = await Hive.openBox<Room>('rooms');
    _loadRooms();
  }

  void _loadRooms() {
    // Carrega os valores da box do Hive e garante que os IDs internos do Hive
    // sejam copiados para o campo 'id' da nossa classe Room, se ainda não tiverem.
    _rooms = _roomBox.values.map((r) {
      if (r.id == null) {
        r.id = r.key; // Atribui o Hive's internal key as our 'id' if null
        r.save(); // Salva a mudança na box
      }
      return r;
    }).toList();
    notifyListeners();
  }

  // NOVO: Adicionado getRoomById para consistência
  Room? getRoomById(int? id) {
    if (id == null) return null;
    return _rooms.firstWhere((r) => r.id == id, orElse: () => null as Room);
  }


  Future<void> addRoom(Room room) async {
    if (room.id == null) {
      // Quando uma nova sala é adicionada, Hive gera um 'key' automaticamente.
      // Usamos esse 'key' como o nosso 'id' manual para referência.
      room.id = await _roomBox.add(room); // Isso adiciona e retorna a key
      await room.save(); // Garante que o ID recém-atribuído seja salvo
    } else {
      await _roomBox.put(room.id!, room);
    }
    _loadRooms();
  }

  Future<void> updateRoom(Room room) async {
    // Garante que o 'id' existe antes de tentar atualizar
    if (room.id != null) {
      await _roomBox.put(room.id!, room);
      _loadRooms();
    }
  }

  Future<void> deleteRoom(int id) async {
    await _roomBox.delete(id);
    _loadRooms();
  }
}