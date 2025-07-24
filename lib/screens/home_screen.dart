import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_class_schedule/providers/schedule_provider.dart';
import 'package:my_class_schedule/models/schedule.dart';
import 'package:my_class_schedule/screens/add_edit_schedule_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _daysOfWeek = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];

  @override
  void initState() {
    super.initState();
    
    int initialIndex = DateTime.now().weekday - 1;
    if (initialIndex < 0 || initialIndex > 6) initialIndex = 0;

    _tabController = TabController(length: _daysOfWeek.length, vsync: this, initialIndex: initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Cronograma'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _daysOfWeek.map((day) => Tab(text: day)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(_daysOfWeek.length, (index) {
          return Consumer<ScheduleProvider>(
            builder: (context, scheduleProvider, child) {
              
              final schedulesForDay = scheduleProvider.getSchedulesForDay(index);
              if (schedulesForDay.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhum agendamento para este dia.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }
              return ListView.builder(
                itemCount: schedulesForDay.length,
                itemBuilder: (context, i) {
                  final schedule = schedulesForDay[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                    color: schedule.color.withOpacity(0.15),
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      title: Text(
                        schedule.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            '${_formatTime(schedule.startTime, context)} - ${_formatTime(schedule.endTime, context)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          if (schedule.room != null && schedule.room!.isNotEmpty)
                            Text('Sala: ${schedule.room}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                          if (schedule.teacher != null && schedule.teacher!.isNotEmpty)
                            Text('Professor: ${schedule.teacher}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                          if (schedule.notes != null && schedule.notes!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text('Notas: ${schedule.notes}', style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.deepPurple),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AddEditScheduleScreen(schedule: schedule),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _confirmDelete(context, schedule.id!);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddEditScheduleScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatTime(TimeOfDay time, BuildContext context) {
    
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt);
  }

  Future<void> _confirmDelete(BuildContext context, int scheduleId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Tem certeza que deseja excluir este agendamento?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Provider.of<ScheduleProvider>(context, listen: false)
                    .deleteSchedule(scheduleId);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}