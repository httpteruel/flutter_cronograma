import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:my_class_schedule/models/schedule.dart';
import 'package:my_class_schedule/models/professor.dart';
import 'package:my_class_schedule/models/room.dart';
import 'package:my_class_schedule/providers/schedule_provider.dart';
import 'package:my_class_schedule/providers/professor_provider.dart';
import 'package:my_class_schedule/providers/room_provider.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  // Variáveis de estado para os filtros e ordenação
  int? _selectedDayFilter;
  int? _selectedProfessorFilter;
  int? _selectedRoomFilter;
  String _selectedSortOrder = 'day_asc'; // Ordem padrão: por dia, depois hora

  // Mapeamento dos dias da semana para exibição nos filtros
  final List<String> _days = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo'
  ];

  // Mapeamento das opções de ordenação para exibição
  final Map<String, String> _sortOptions = {
    'day_asc': 'Dia e Horário', // Adicionado como a primeira opção padrão
    'name_asc': 'Nome da Aula (A-Z)',
    'name_desc': 'Nome da Aula (Z-A)',
    'time_asc': 'Horário (Crescente)',
    'time_desc': 'Horário (Decrescente)',
  };

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final professorProvider = Provider.of<ProfessorProvider>(context);
    final roomProvider = Provider.of<RoomProvider>(context);

    // Obtém a lista de agendamentos filtrada e ordenada
    final List<Schedule> filteredAndSortedSchedules =
        scheduleProvider.getFilteredAndSortedSchedules(
      dayOfWeek: _selectedDayFilter,
      professorId: _selectedProfessorFilter,
      roomId: _selectedRoomFilter,
      sortBy: _selectedSortOrder,
    );

    // Opções para Dropdown de dias da semana (com "Todos os Dias")
    final List<DropdownMenuItem<int?>> dayDropdownItems = [
      DropdownMenuItem<int?>(value: null, child: Text('Todos os Dias')),
      ..._days.asMap().entries.map((entry) {
        return DropdownMenuItem<int?>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
    ];

    // Opções para Dropdown de professores (com "Todos os Professores")
    final List<DropdownMenuItem<int?>> professorDropdownItems = [
      DropdownMenuItem<int?>(value: null, child: Text('Todos os Professores')),
      ...professorProvider.professors.map((p) => DropdownMenuItem<int?>(
        value: p.id,
        child: Text(p.name),
      )).toList(),
    ];

    // Opções para Dropdown de salas (com "Todas as Salas")
    final List<DropdownMenuItem<int?>> roomDropdownItems = [
      DropdownMenuItem<int?>(value: null, child: Text('Todas as Salas')),
      ...roomProvider.rooms.map((r) => DropdownMenuItem<int?>(
        value: r.id, // AQUI ESTAVA O SEU ERRO, MAS ESSA LINHA JÁ ESTAVA CORRETA NO CÓDIGO FORNECIDO ANTERIORMENTE.
        child: Text(r.name),
      )).toList(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Relatórios de Agendamentos'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, professorProvider.professors, roomProvider.rooms),
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () => _showSortDialog(context),
          ),
        ],
      ),
      body: filteredAndSortedSchedules.isEmpty
          ? Center(
              child: Text(
                'Nenhum agendamento encontrado com os filtros aplicados.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: filteredAndSortedSchedules.length,
              itemBuilder: (context, index) {
                final schedule = filteredAndSortedSchedules[index];
                final Professor? professor = professorProvider.getProfessorById(schedule.professorId);
                final Room? room = roomProvider.getRoomById(schedule.roomId);

                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  color: schedule.color.withOpacity(0.8),
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
                          '${_days[schedule.dayOfWeek]}, ' // Exibe o dia da semana
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
                  ),
                );
              },
            ),
    );
  }

  // --- Diálogo de Filtros ---
  Future<void> _showFilterDialog(
    BuildContext context,
    List<Professor> professors,
    List<Room> rooms,
  ) async {
    int? tempDayFilter = _selectedDayFilter;
    int? tempProfessorFilter = _selectedProfessorFilter;
    int? tempRoomFilter = _selectedRoomFilter;

    // Usamos um Builder para criar um novo BuildContext para o StatefulBuilder
    // Assim, podemos usar setState dentro do diálogo sem reconstruir a tela inteira.
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Filtrar Agendamentos'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int?>(
                      value: tempDayFilter,
                      decoration: InputDecoration(labelText: 'Dia da Semana'),
                      items: [
                        DropdownMenuItem<int?>(value: null, child: Text('Todos os Dias')),
                        ..._days.asMap().entries.map((entry) {
                          return DropdownMenuItem<int?>(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                      ],
                      onChanged: (newValue) {
                        setState(() { // Usa o setState do StatefulBuilder
                          tempDayFilter = newValue;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<int?>(
                      value: tempProfessorFilter,
                      decoration: InputDecoration(labelText: 'Professor'),
                      items: [
                        DropdownMenuItem<int?>(value: null, child: Text('Todos os Professores')),
                        ...professors.map((p) => DropdownMenuItem<int?>(
                          value: p.id,
                          child: Text(p.name),
                        )).toList(),
                      ],
                      onChanged: (newValue) {
                        setState(() { // Usa o setState do StatefulBuilder
                          tempProfessorFilter = newValue;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<int?>(
                      value: tempRoomFilter,
                      decoration: InputDecoration(labelText: 'Sala'),
                      items: [
                        DropdownMenuItem<int?>(value: null, child: Text('Todas as Salas')),
                        ...rooms.map((r) => DropdownMenuItem<int?>(
                          value: r.id,
                          child: Text(r.name),
                        )).toList(),
                      ],
                      onChanged: (newValue) {
                        setState(() { // Usa o setState do StatefulBuilder
                          tempRoomFilter = newValue;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Fecha o diálogo
                  },
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    // Atualiza o estado da tela principal para aplicar os filtros
                    this.setState(() { // Note o 'this.setState' para diferenciar do setState do StatefulBuilder
                      _selectedDayFilter = tempDayFilter;
                      _selectedProfessorFilter = tempProfessorFilter;
                      _selectedRoomFilter = tempRoomFilter;
                    });
                    Navigator.of(dialogContext).pop(); // Fecha o diálogo
                  },
                  child: Text('Aplicar Filtros'),
                ),
                TextButton(
                  onPressed: () {
                    // Limpa os filtros no estado da tela principal
                    this.setState(() { // Note o 'this.setState'
                      _selectedDayFilter = null;
                      _selectedProfessorFilter = null;
                      _selectedRoomFilter = null;
                    });
                    Navigator.of(dialogContext).pop(); // Fecha o diálogo
                  },
                  child: Text('Limpar Filtros'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- Diálogo de Ordenação ---
  Future<void> _showSortDialog(BuildContext context) async {
    String? tempSortOrder = _selectedSortOrder;

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Ordenar Por'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _sortOptions.entries.map((entry) {
                    return RadioListTile<String>(
                      title: Text(entry.value),
                      value: entry.key,
                      groupValue: tempSortOrder,
                      onChanged: (String? newValue) {
                        setState(() { // Usa o setState do StatefulBuilder
                          tempSortOrder = newValue;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Fecha o diálogo
                  },
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    // Atualiza o estado da tela principal para aplicar a ordenação
                    this.setState(() { // Note o 'this.setState'
                      _selectedSortOrder = tempSortOrder!;
                    });
                    Navigator.of(dialogContext).pop(); // Fecha o diálogo
                  },
                  child: Text('Aplicar Ordenação'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}