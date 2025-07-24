import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_class_schedule/models/professor.dart';

class ProfessorProvider with ChangeNotifier {
  late Box<Professor> _professorBox;
  List<Professor> _professors = [];

  List<Professor> get professors => _professors;

  ProfessorProvider() {
    _initHiveAndLoadProfessors();
  }

  Future<void> _initHiveAndLoadProfessors() async {
    _professorBox = await Hive.openBox<Professor>('professors');
    _loadProfessors();
  }

  void _loadProfessors() {
    // Carrega os valores da box do Hive e garante que os IDs internos do Hive
    // sejam copiados para o campo 'id' da nossa classe Professor, se ainda não tiverem.
    _professors = _professorBox.values.map((p) {
      if (p.id == null) {
        p.id = p.key; // Atribui o Hive's internal key as our 'id' if null
        p.save(); // Salva a mudança na box
      }
      return p;
    }).toList();
    notifyListeners();
  }

  // NOVO: Adicionado getProfessorById para consistência
  Professor? getProfessorById(int? id) {
    if (id == null) return null;
    return _professors.firstWhere((p) => p.id == id, orElse: () => null as Professor);
  }


  Future<void> addProfessor(Professor professor) async {
    if (professor.id == null) {
      // Quando um novo professor é adicionado, Hive gera um 'key' automaticamente.
      // Usamos esse 'key' como o nosso 'id' manual para referência.
      professor.id = await _professorBox.add(professor); // Isso adiciona e retorna a key
      await professor.save(); // Garante que o ID recém-atribuído seja salvo
    } else {
      await _professorBox.put(professor.id!, professor);
    }
    _loadProfessors();
  }

  Future<void> updateProfessor(Professor professor) async {
    // Garante que o 'id' existe antes de tentar atualizar
    if (professor.id != null) {
      await _professorBox.put(professor.id!, professor);
      _loadProfessors();
    }
  }

  Future<void> deleteProfessor(int id) async {
    await _professorBox.delete(id);
    _loadProfessors();
  }
}