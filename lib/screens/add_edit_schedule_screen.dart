import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_class_schedule/models/schedule.dart';
import 'package:my_class_schedule/providers/schedule_provider.dart';
import 'package:intl/intl.dart';

class AddEditScheduleScreen extends StatefulWidget {
  final Schedule? schedule;

  AddEditScheduleScreen({this.schedule});

  @override
  _AddEditScheduleScreenState createState() => _AddEditScheduleScreenState();
}

class _AddEditScheduleScreenState extends State<AddEditScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late int _dayOfWeek;
  String? _room;
  String? _teacher;
  Color _color = Colors.blue;
  String? _notes;

  final List<String> _daysOfWeekNames = [
    'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado', 'Domingo'
  ];

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      _name = widget.schedule!.name;
      _startTime = widget.schedule!.startTime;
      _endTime = widget.schedule!.endTime;
      _dayOfWeek = widget.schedule!.dayOfWeek;
      _room = widget.schedule!.room;
      _teacher = widget.schedule!.teacher;
      _color = widget.schedule!.color;
      _notes = widget.schedule!.notes;
    } else {
      _name = '';
      _startTime = TimeOfDay.now();
      _endTime = TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));
      _dayOfWeek = DateTime.now().weekday - 1;
      if (_dayOfWeek < 0 || _dayOfWeek > 6) _dayOfWeek = 0;
    }
  }

  Future<void> _pickTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
      helpText: isStartTime ? 'Selecione a Hora de Início' : 'Selecione a Hora de Término',
      builder: (BuildContext context, Widget? child) {
      
        
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
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

  String _formatTime(TimeOfDay time, BuildContext context) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.schedule == null ? 'Adicionar Agendamento' : 'Editar Agendamento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(
                  labelText: 'Nome da Aula/Matéria',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um nome para o agendamento.';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text('Hora de Início: ${_formatTime(_startTime, context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () => _pickTime(context, true),
                tileColor: Colors.grey[100],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              const SizedBox(height: 8),
              ListTile(
                title: Text('Hora de Término: ${_formatTime(_endTime, context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () => _pickTime(context, false),
                tileColor: Colors.grey[100],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _dayOfWeek,
                decoration: const InputDecoration(
                  labelText: 'Dia da Semana',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                items: _daysOfWeekNames
                    .asMap()
                    .entries
                    .map((entry) {
                      return DropdownMenuItem<int>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _dayOfWeek = value!;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecione um dia da semana.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _room,
                decoration: const InputDecoration(
                  labelText: 'Sala (Opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.meeting_room),
                ),
                onSaved: (value) => _room = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _teacher,
                decoration: const InputDecoration(
                  labelText: 'Professor (Opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                onSaved: (value) => _teacher = value,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Color>(
                value: _color,
                decoration: const InputDecoration(
                  labelText: 'Cor do Agendamento',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.color_lens),
                ),
                items: _availableColors
                    .map((color) {
                      return DropdownMenuItem<Color>(
                        value: color,
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(color.toString().split('.').last.replaceAll('MaterialColor(', '').replaceAll(')', '')),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _color = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _notes,
                decoration: const InputDecoration(
                  labelText: 'Notas (Opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 3,
                onSaved: (value) => _notes = value,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    if (_endTime.hour * 60 + _endTime.minute <= _startTime.hour * 60 + _startTime.minute) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('A hora de término deve ser posterior à hora de início.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final newSchedule = Schedule(
                      id: widget.schedule?.id,
                      name: _name!,
                      startTime: _startTime,
                      endTime: _endTime,
                      dayOfWeek: _dayOfWeek,
                      room: _room,
                      teacher: _teacher,
                      color: _color,
                      notes: _notes,
                    );

                    if (widget.schedule == null) {
                      
                      Provider.of<ScheduleProvider>(context, listen: false)
                          .addSchedule(newSchedule);
                    } else {
                      
                      Provider.of<ScheduleProvider>(context, listen: false)
                          .updateSchedule(newSchedule);
                    }
                    Navigator.of(context).pop();
                  }
                },
                icon: Icon(widget.schedule == null ? Icons.add : Icons.save),
                label: Text(widget.schedule == null ? 'Adicionar Agendamento' : 'Salvar Alterações'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}