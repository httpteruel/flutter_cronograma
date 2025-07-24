import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_class_schedule/models/subject.dart';

class SubjectProvider with ChangeNotifier {
  late Box<Subject> _subjectBox;
  List<Subject> _subjects = [];

  List<Subject> get subjects => _subjects;

  SubjectProvider() {
    _initHiveAndLoadSubjects();
  }

  Future<void> _initHiveAndLoadSubjects() async {
    _subjectBox = await Hive.openBox<Subject>('subjects');
    _loadSubjects();
  }

  void _loadSubjects() {
    _subjects = _subjectBox.values.map((s) {
      if (s.id == null) {
        s.id = s.key;
        s.save();
      }
      return s;
    }).toList();
    notifyListeners();
  }

  Subject? getSubjectById(int? id) {
    if (id == null) return null;
    return _subjects.firstWhere((s) => s.id == id, orElse: () => null as Subject);
  }

  Future<void> addSubject(Subject subject) async {
    if (subject.id == null) {
      subject.id = await _subjectBox.add(subject);
      await subject.save();
    } else {
      await _subjectBox.put(subject.id!, subject);
    }
    _loadSubjects();
  }

  Future<void> updateSubject(Subject subject) async {
    if (subject.id != null) {
      await _subjectBox.put(subject.id!, subject);
      _loadSubjects();
    }
  }

  Future<void> deleteSubject(int id) async {
    // TODO: Considerar lógica para desvincular de tópicos antes de deletar
    await _subjectBox.delete(id);
    _loadSubjects();
  }
}