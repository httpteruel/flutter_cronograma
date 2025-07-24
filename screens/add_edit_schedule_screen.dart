import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // Importação necessária
import 'package:intl/intl.dart';

import 'package:my_class_schedule/models/schedule.dart';
import 'package:my_class_schedule/models/professor.dart';
import 'package:my_class_schedule/models/room.dart';
import 'package:my_class_schedule/models/topic.dart';

import 'package:my_class_schedule/providers/schedule_provider.dart';
import 'package:my_class_schedule/providers/professor_provider.dart';
import 'package:my_class_schedule/providers/room_provider.dart';
import 'package:my_class_schedule/providers/topic_provider.dart';

class AddEditScheduleScreen extends StatefulWidget {
  final Schedule? schedule;

  AddEditScheduleScreen({this.schedule});

  @override
  _AddEditScheduleScreenState createState() => _AddEditScheduleScreenState();
}

class _AddEditScheduleScreenState extends State<AddEditScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late int _selectedDayOfWeek;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  Color _selectedColor = Colors.deepPurple;
  late TextEditingController _notesController;
  int? _selectedProfessorId;
  int? _selectedRoomId;
  List<int> _selectedTopicIds = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _notesController = TextEditingController();

    if (widget.schedule != null) {
      // Modo de edição
      _nameController.text = widget.schedule!.name;
      _selectedDayOfWeek = widget.schedule!.dayOfWeek;
      _startTime = widget.schedule!.startTime;
      _endTime = widget.schedule!.endTime;
      _selectedColor = widget.schedule!.color;
      _notesController.text = widget.schedule!.notes ?? '';
      _selectedProfessorId = widget.schedule!.professorId;
      _selectedRoomId = widget.schedule!.roomId;
      _selectedTopicIds = List.from(widget.schedule!.topicIds);
    } else {
      // Modo de adição
      _selectedDayOfWeek = DateTime.now().weekday - 1; // Dia atual padrão (0=Segunda)
      _startTime = TimeOfDay.now();
      _endTime = TimeOfDay.fromDateTime(DateTime.now().add(Duration(hours: 1)));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? (_startTime ?? TimeOfDay.now()) : (_endTime ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecione uma cor'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: (color) {
                setState(() {
                  _selectedColor = color;
                });
              },
              // A linha 'pickerAreaHeightladderRatio: 1.2,' FOI REMOVIDA AQUI
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveSchedule() {
    if (_formKey.currentState!.validate()) {
      if (_startTime == null || _endTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, selecione os horários de início e fim.'))
        );
        return;
      }

      // Validação de horário de fim ser depois do início
      final now = DateTime.now();
      final DateTime startDateTime = DateTime(now.year, now.month, now.day, _startTime!.hour, _startTime!.minute);
      final DateTime endDateTime = DateTime(now.year, now.month, now.day, _endTime!.hour, _endTime!.minute);

      if (endDateTime.isBefore(startDateTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('O horário de término não pode ser antes do horário de início.'))
        );
        return;
      }

      final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);

      final newSchedule = Schedule(
        id: widget.schedule?.id,
        name: _nameController.text,
        dayOfWeek: _selectedDayOfWeek,
        startTime: _startTime!,
        endTime: _endTime!,
        color: _selectedColor,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        professorId: _selectedProfessorId,
        roomId: _selectedRoomId,
        topicIds: _selectedTopicIds,
      );

      if (widget.schedule == null) {
        scheduleProvider.addSchedule(newSchedule);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Agendamento cadastrado!')));
      } else {
        scheduleProvider.updateSchedule(newSchedule);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Agendamento atualizado!')));
      }
      Navigator.pop(context); // Volta para a tela anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    final professorProvider = Provider.of<ProfessorProvider>(context);
    final roomProvider = Provider.of<RoomProvider>(context);
    final topicProvider = Provider.of<TopicProvider>(context);

    final List<Professor> availableProfessors = professorProvider.professors;
    final List<Room> availableRooms = roomProvider.rooms;
    final List<Topic> availableTopics = topicProvider.topics;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.schedule == null ? 'Novo Agendamento' : 'Editar Agendamento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome da Aula/Evento',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome da aula.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedDayOfWeek,
                decoration: InputDecoration(
                  labelText: 'Dia da Semana',
                  border: OutlineInputBorder(),
                ),
                items: <DropdownMenuItem<int>>[
                  DropdownMenuItem(value: 0, child: Text('Segunda-feira')),
                  DropdownMenuItem(value: 1, child: Text('Terça-feira')),
                  DropdownMenuItem(value: 2, child: Text('Quarta-feira')),
                  DropdownMenuItem(value: 3, child: Text('Quinta-feira')),
                  DropdownMenuItem(value: 4, child: Text('Sexta-feira')),
                  DropdownMenuItem(value: 5, child: Text('Sábado')),
                  DropdownMenuItem(value: 6, child: Text('Domingo')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedDayOfWeek = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context, true),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Hora de Início',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _startTime != null ? _startTime!.format(context) : 'Selecionar Hora',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context, false),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Hora de Fim',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _endTime != null ? _endTime!.format(context) : 'Selecionar Hora',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedProfessorId,
                decoration: InputDecoration(
                  labelText: 'Professor (Opcional)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: null, child: Text('Nenhum Professor')),
                  ...availableProfessors.map((prof) => DropdownMenuItem(
                    value: prof.id,
                    child: Text(prof.name),
                  )).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedProfessorId = value;
                  });
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedRoomId,
                decoration: InputDecoration(
                  labelText: 'Sala (Opcional)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: null, child: Text('Nenhuma Sala')),
                  ...availableRooms.map((room) => DropdownMenuItem(
                    value: room.id,
                    child: Text(room.name),
                  )).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRoomId = value;
                  });
                },
              ),
              SizedBox(height: 16),
              Text('Selecione os Tópicos (Opcional):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              availableTopics.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('Nenhum tópico cadastrado. Cadastre tópicos primeiro.', style: TextStyle(color: Colors.red)),
                    )
                  : Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: availableTopics.map((topic) {
                        final isSelected = _selectedTopicIds.contains(topic.id);
                        return ChoiceChip(
                          label: Text(topic.name),
                          selected: isSelected,
                          selectedColor: Theme.of(context).primaryColor.withOpacity(0.7),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedTopicIds.add(topic.id!);
                              } else {
                                _selectedTopicIds.remove(topic.id!);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
              SizedBox(height: 16),
              ListTile(
                title: Text('Cor do Agendamento'),
                trailing: GestureDetector(
                  onTap: _pickColor,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notas (Opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveSchedule,
                child: Text(widget.schedule == null ? 'Salvar Agendamento' : 'Atualizar Agendamento'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}