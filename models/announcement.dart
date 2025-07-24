class Announcement {
  final int userId;
  final int id;
  final String title;
  final String body;

  Announcement({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
  });

  // Factory constructor para criar uma instância de Announcement a partir de um JSON
  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      userId: json['userId'] as int,
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }

  // Método para converter uma instância de Announcement para JSON (útil para POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'id': id,
      'title': title,
      'body': body,
    };
  }
}