import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_class_schedule/models/subject.dart';
import 'package:my_class_schedule/providers/subject_provider.dart';

class ManageSubjectsScreen extends StatefulWidget {
  @override
  _ManageSubjectsScreenState createState() => _ManageSubjectsScreenState();
}

class _ManageSubjectsScreenState extends State<ManageSubjectsScreen> {
  final _nameController = TextEditingController();
  Subject? _editingSubject;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveSubject() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('O nome da matéria não pode ser vazio!'))
      );
      return;
    }

    final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);

    if (_editingSubject == null) {
      // Adicionar nova matéria
      subjectProvider.addSubject(Subject(
        name: _nameController.text,
      ));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Matéria cadastrada!')));
    } else {
      // Atualizar matéria existente
      subjectProvider.updateSubject(_editingSubject!.copyWith(
        name: _nameController.text,
      ));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Matéria atualizada!')));
      _editingSubject = null; // Limpa o estado de edição
    }

    _nameController.clear();
    FocusScope.of(context).unfocus(); // Fecha o teclado
  }

  void _editSubject(Subject subject) {
    setState(() {
      _editingSubject = subject;
      _nameController.text = subject.name;
    });
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, Subject subject) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir a matéria "${subject.name}"?'),
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
                Provider.of<SubjectProvider>(context, listen: false).deleteSubject(subject.id!);
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Matéria excluída!'))
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
    final subjectProvider = Provider.of<SubjectProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciar Matérias'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome da Matéria (ex: Biologia, Matemática)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveSubject,
              child: Text(_editingSubject == null ? 'Cadastrar Matéria' : 'Atualizar Matéria'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            if (_editingSubject != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _editingSubject = null;
                      _nameController.clear();
                    });
                  },
                  child: Text('Cancelar Edição'),
                ),
              ),
            SizedBox(height: 24),
            Text(
              'Matérias Cadastradas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: subjectProvider.subjects.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhuma matéria cadastrada ainda.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: subjectProvider.subjects.length,
                      itemBuilder: (context, index) {
                        final subject = subjectProvider.subjects[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 2,
                          child: ListTile(
                            title: Text(subject.name),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editSubject(subject),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _showDeleteConfirmationDialog(context, subject),
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
      ),
    );
  }
}