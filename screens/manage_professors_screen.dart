import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_class_schedule/models/professor.dart';
import 'package:my_class_schedule/providers/professor_provider.dart';

class ManageProfessorsScreen extends StatefulWidget {
  @override
  _ManageProfessorsScreenState createState() => _ManageProfessorsScreenState();
}

class _ManageProfessorsScreenState extends State<ManageProfessorsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Professor? _editingProfessor; // Professor sendo editado

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _addOrUpdateProfessor() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final professorProvider = Provider.of<ProfessorProvider>(context, listen: false);

      if (_editingProfessor == null) {
        // Adicionar novo professor
        professorProvider.addProfessor(Professor(
          name: _nameController.text,
          email: _emailController.text.isEmpty ? null : _emailController.text,
          phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        ));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Professor adicionado!')));
      } else {
        // Atualizar professor existente
        professorProvider.updateProfessor(_editingProfessor!.copyWith(
          name: _nameController.text,
          email: _emailController.text.isEmpty ? null : _emailController.text,
          phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        ));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Professor atualizado!')));
        _editingProfessor = null; // Limpa o estado de edição
      }

      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      FocusScope.of(context).unfocus(); // Fecha o teclado
    }
  }

  void _startEditing(Professor professor) {
    setState(() {
      _editingProfessor = professor;
      _nameController.text = professor.name;
      _emailController.text = professor.email ?? '';
      _phoneController.text = professor.phone ?? '';
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingProfessor = null;
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final professorProvider = Provider.of<ProfessorProvider>(context);
    final professors = professorProvider.professors;

    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciar Professores'),
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
                    decoration: InputDecoration(labelText: 'Nome do Professor'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o nome do professor.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email (Opcional)'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(labelText: 'Telefone (Opcional)'),
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _addOrUpdateProfessor,
                        child: Text(_editingProfessor == null ? 'Adicionar Professor' : 'Salvar Alterações'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      if (_editingProfessor != null)
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
            child: professors.isEmpty
                ? Center(child: Text('Nenhum professor cadastrado.'))
                : ListView.builder(
                    itemCount: professors.length,
                    itemBuilder: (context, index) {
                      final professor = professors[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: ListTile(
                          title: Text(professor.name),
                          subtitle: Text('${professor.email ?? ''} ${professor.phone ?? ''}'.trim()),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _startEditing(professor),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  // TODO: Adicionar um diálogo de confirmação para exclusão
                                  professorProvider.deleteProfessor(professor.id!);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Professor excluído!'))
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