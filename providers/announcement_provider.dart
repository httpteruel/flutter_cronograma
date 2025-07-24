import 'package:flutter/material.dart';
import 'package:my_class_schedule/models/announcement.dart';
import 'package:my_class_schedule/services/announcement_api_service.dart';

class AnnouncementProvider with ChangeNotifier {
  final AnnouncementApiService _apiService = AnnouncementApiService();
  List<Announcement> _announcements = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Announcement> get announcements => _announcements;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AnnouncementProvider() {
    fetchAndLoadAnnouncements(); // Busca comunicados ao inicializar
  }

  Future<void> fetchAndLoadAnnouncements() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _announcements = await _apiService.fetchAnnouncements();
      _errorMessage = null; // Limpa qualquer erro anterior
    } catch (e) {
      _errorMessage = 'Erro ao carregar comunicados: $e';
      _announcements = []; // Limpa a lista em caso de erro
      print(_errorMessage); // Para depuração
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}