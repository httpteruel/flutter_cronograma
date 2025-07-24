import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_class_schedule/models/room.dart';
import 'package:my_class_schedule/providers/room_provider.dart';

class ManageRoomsScreen extends StatefulWidget {
  @override
  _ManageRoomsScreenState createState() => _ManageRoomsScreenState();
}

class _ManageRoomsScreenState extends State<ManageRoomsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  Room? _editingRoom; // Sala sendo editada

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _addOrUpdateRoom() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final roomProvider = Provider.of<RoomProvider>(context, listen: false);

      // Converte a capacidade para int, se não for vazia
      final int? capacity = _capacityController.text.isEmpty
          ? null
          : int.tryParse(_capacityController.text);

      if (_editingRoom == null) {
        // Adicionar nova sala
        roomProvider.addRoom(Room(
          name: _nameController.text,
          capacity: capacity,
          location: _locationController.text.isEmpty ? null : _locationController.text,
        ));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sala adicionada!')));
      } else {
        // Atualizar sala existente
        roomProvider.updateRoom(_editingRoom!.copyWith(
          name: _nameController.text,
          capacity: capacity,
          location: _locationController.text.isEmpty ? null : _locationController.text,
        ));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sala atualizada!')));
        _editingRoom = null; // Limpa o estado de edição
      }

      _nameController.clear();
      _capacityController.clear();
      _locationController.clear();
      FocusScope.of(context).unfocus(); // Fecha o teclado
    }
  }

  void _startEditing(Room room) {
    setState(() {
      _editingRoom = room;
      _nameController.text = room.name;
      _capacityController.text = room.capacity?.toString() ?? '';
      _locationController.text = room.location ?? '';
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingRoom = null;
      _nameController.clear();
      _capacityController.clear();
      _locationController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);
    final rooms = roomProvider.rooms;

    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciar Salas'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Nome da Sala'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o nome da sala.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _capacityController,
                    decoration: InputDecoration(labelText: 'Capacidade (Opcional)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                        return 'Por favor, insira um número válido para a capacidade.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(labelText: 'Localização (Opcional)'),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _addOrUpdateRoom,
                        child: Text(_editingRoom == null ? 'Adicionar Sala' : 'Salvar Alterações'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      if (_editingRoom != null)
                        TextButton(
                          onPressed: _cancelEditing,
                          child: Text('Cancelar Edição', style: TextStyle(color: Colors.grey)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Divider(),
          Expanded(
            child: rooms.isEmpty
                ? Center(child: Text('Nenhuma sala cadastrada.'))
                : ListView.builder(
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: ListTile(
                          title: Text(room.name),
                          subtitle: Text('${room.capacity != null ? 'Cap: ${room.capacity}' : ''} ${room.location ?? ''}'.trim()),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _startEditing(room),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  // TODO: Adicionar um diálogo de confirmação para exclusão
                                  roomProvider.deleteRoom(room.id!);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Sala excluída!'))
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}