import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// Importações de Modelos
import 'package:my_class_schedule/models/schedule.dart';
import 'package:my_class_schedule/models/professor.dart';
import 'package:my_class_schedule/models/room.dart';
import 'package:my_class_schedule/models/topic.dart';
import 'package:my_class_schedule/models/subject.dart';

// Importações de Providers
import 'package:my_class_schedule/providers/schedule_provider.dart';
import 'package:my_class_schedule/providers/professor_provider.dart';
import 'package:my_class_schedule/providers/room_provider.dart';
import 'package:my_class_schedule/providers/topic_provider.dart';
import 'package:my_class_schedule/providers/subject_provider.dart';

// Importações de Telas de Gerenciamento e Edição
import 'package:my_class_schedule/screens/add_edit_schedule_screen.dart';
import 'package:my_class_schedule/screens/manage_professors_screen.dart';
import 'package:my_class_schedule/screens/manage_rooms_screen.dart';
import 'package:my_class_schedule/screens/reports_screen.dart';
import 'package:my_class_schedule/screens/manage_topics_screen.dart';
import 'package:my_class_schedule/screens/manage_subjects_screen.dart';
import 'package:my_class_schedule/screens/announcements_screen.dart'; // NOVO: Importa a tela de comunicados

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _days = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo'
  ];

  @override
  void initState() {
    super.initState();
    // Define o dia inicial da TabBar para o dia da semana atual
    // DateTime.now().weekday retorna 1 para Segunda, 7 para Domingo.
    // Nossa lista de dias é 0-indexed (0=Segunda, 6=Domingo).
    int initialDay = DateTime.now().weekday - 1;
    if (initialDay < 0 || initialDay >= _days.length) {
      initialDay = 0; // Fallback para Segunda-feira se o dia estiver fora do esperado
    }
    _tabController = TabController(length: _days.length, vsync: this, initialIndex: initialDay);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Diálogo de confirmação para exclusão de agendamento
  Future<void> _showDeleteConfirmationDialog(BuildContext context, Schedule schedule) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Usuário deve tocar em um botão para fechar
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir o agendamento "${schedule.name}"?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text('Excluir', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Provider.of<ScheduleProvider>(context, listen: false).deleteSchedule(schedule.id!);
                Navigator.of(dialogContext).pop(); // Fecha o diálogo
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Agendamento excluído!'))
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Acessa os providers para obter os dados necessários
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final professorProvider = Provider.of<ProfessorProvider>(context);
    final roomProvider = Provider.of<RoomProvider>(context);
    final topicProvider = Provider.of<TopicProvider>(context);
    final subjectProvider = Provider.of<SubjectProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Meu Cronograma de Aulas'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true, // Permite rolar se houver muitos dias
          tabs: _days.map((day) => Tab(text: day)).toList(),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Opções do Aplicativo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gerencie seus dados e veja comunicados',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Gerenciar Professores'),
              onTap: () {
                Navigator.pop(context); // Fecha o drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageProfessorsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.meeting_room),
              title: Text('Gerenciar Salas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageRoomsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.school),
              title: Text('Gerenciar Matérias'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageSubjectsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.topic),
              title: Text('Gerenciar Tópicos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageTopicsScreen()),
                );
              },
            ),
            Divider(), // Divisor para separar as opções de gerenciamento
            ListTile(
              leading: Icon(Icons.campaign), // Ícone para comunicados
              title: Text('Comunicados da Escola'), // NOVO: Item do Drawer para Comunicados
              onTap: () {
                Navigator.pop(context); // Fecha o drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AnnouncementsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.bar_chart),
              title: Text('Relatórios de Agendamentos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReportsScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _days.asMap().entries.map((entry) {
          int dayIndex = entry.key; // 0 para Segunda, 1 para Terça, etc.
          final schedulesForDay = scheduleProvider.getSchedulesForDay(dayIndex);

          if (schedulesForDay.isEmpty) {
            return Center(
              child: Text(
                'Nenhum agendamento para ${entry.value}.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: schedulesForDay.length,
            itemBuilder: (context, index) {
              final schedule = schedulesForDay[index];
              // Recupera os objetos completos Professor e Room pelos IDs
              final Professor? professor = professorProvider.getProfessorById(schedule.professorId);
              final Room? room = roomProvider.getRoomById(schedule.roomId);
              
              // Recupera os tópicos e suas matérias para exibição
              final List<Topic> associatedTopics = schedule.topicIds
                  .map((id) => topicProvider.getTopicById(id))
                  .where((topic) => topic != null) // Filtra nulos se um ID não encontrar um tópico
                  .cast<Topic>() // Garante que a lista seja de Topic
                  .toList();

              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8.0),
                color: schedule.color.withOpacity(0.8), // Usa a cor do agendamento
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.0),
                  title: Text(
                    schedule.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(
                        '${DateFormat.Hm().format(DateTime(2023, 1, 1, schedule.startTime.hour, schedule.startTime.minute))} - '
                        '${DateFormat.Hm().format(DateTime(2023, 1, 1, schedule.endTime.hour, schedule.endTime.minute))}',
                        style: TextStyle(color: Colors.white70),
                      ),
                      if (professor != null)
                        Text(
                          'Professor: ${professor.name}',
                          style: TextStyle(color: Colors.white70),
                        ),
                      if (room != null)
                        Text(
                          'Sala: ${room.name}',
                          style: TextStyle(color: Colors.white70),
                        ),
                      // Exibir tópicos e suas matérias associadas
                      if (associatedTopics.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tópicos:', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                              ...associatedTopics.map((topic) {
                                final List<Subject> associatedSubjects = topic.subjectIds
                                    .map((id) => subjectProvider.getSubjectById(id))
                                    .where((subject) => subject != null)
                                    .cast<Subject>()
                                    .toList();
                                String subjectsText = associatedSubjects.isNotEmpty
                                    ? ' (${associatedSubjects.map((s) => s.name).join(', ')})'
                                    : '';
                                return Text(
                                  '- ${topic.name}$subjectsText',
                                  style: TextStyle(color: Colors.white60),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      if (schedule.notes != null && schedule.notes!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Notas: ${schedule.notes}',
                            style: TextStyle(color: Colors.white60, fontStyle: FontStyle.italic),
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditScheduleScreen(schedule: schedule),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _showDeleteConfirmationDialog(context, schedule),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEditScheduleScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}