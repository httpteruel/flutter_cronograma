import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_class_schedule/providers/announcement_provider.dart';

class AnnouncementsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final announcementProvider = Provider.of<AnnouncementProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Comunicados da Escola'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              announcementProvider.fetchAndLoadAnnouncements(); // Recarregar ao clicar
            },
          ),
        ],
      ),
      body: announcementProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : announcementProvider.errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 60),
                        SizedBox(height: 10),
                        Text(
                          '${announcementProvider.errorMessage}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            announcementProvider.fetchAndLoadAnnouncements(); // Tentar novamente
                          },
                          child: Text('Tentar Novamente'),
                        ),
                      ],
                    ),
                  ),
                )
              : announcementProvider.announcements.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhum comunicado disponível no momento.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: announcementProvider.announcements.length,
                      itemBuilder: (context, index) {
                        final announcement = announcementProvider.announcements[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  announcement.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  announcement.body,
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'ID do Usuário: ${announcement.userId}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}