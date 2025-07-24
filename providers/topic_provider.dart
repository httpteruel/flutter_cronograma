import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_class_schedule/models/topic.dart';
// Pode precisar importar o Subject para exibir em algum lugar, mas não para a lógica do provider em si.

class TopicProvider with ChangeNotifier {
  late Box<Topic> _topicBox;
  List<Topic> _topics = [];

  List<Topic> get topics => _topics;

  TopicProvider() {
    _initHiveAndLoadTopics();
  }

  Future<void> _initHiveAndLoadTopics() async {
    _topicBox = await Hive.openBox<Topic>('topics');
    _loadTopics();
  }

  void _loadTopics() {
    _topics = _topicBox.values.map((t) {
      if (t.id == null) {
        t.id = t.key;
        t.save();
      }
      // Garantir que subjectIds nunca seja null
      t.subjectIds ??= []; // Garante que a lista seja inicializada se for null
      return t;
    }).toList();
    notifyListeners();
  }

  Topic? getTopicById(int? id) {
    if (id == null) return null;
    // Usar firstWhere com orElse para evitar erro se não encontrar
    try {
      return _topics.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addTopic(Topic topic) async {
    if (topic.id == null) {
      topic.id = await _topicBox.add(topic);
      await topic.save();
    } else {
      await _topicBox.put(topic.id!, topic);
    }
    _loadTopics();
  }

  Future<void> updateTopic(Topic topic) async {
    if (topic.id != null) {
      await _topicBox.put(topic.id!, topic);
      _loadTopics();
    }
  }

  Future<void> deleteTopic(int id) async {
    await _topicBox.delete(id);
    _loadTopics();
  }
}