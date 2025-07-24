import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_class_schedule/models/announcement.dart';

class AnnouncementApiService {
  final String baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<Announcement>> fetchAnnouncements() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Announcement.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar comunicados: ${response.statusCode}');
    }
  }

  // Futuramente, poderíamos adicionar métodos para POST, PUT, DELETE aqui.
  // Exemplo (apenas para demonstração, JSONPlaceholder não suporta PUT/POST reais)
  /*
  Future<Announcement> createAnnouncement(Announcement announcement) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(announcement.toJson()),
    );
    if (response.statusCode == 201) { // 201 Created
      return Announcement.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao criar comunicado: ${response.statusCode}');
    }
  }
  */
}