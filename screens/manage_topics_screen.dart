import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_class_schedule/models/topic.dart';
import 'package:my_class_schedule/models/subject.dart'; // NOVO: Importa o modelo Subject
import 'package:my_class_schedule/providers/topic_provider.dart';
import 'package:my_class_schedule/providers/subject_provider.dart'; // NOVO: Importa o SubjectProvider

class ManageTopicsScreen extends StatefulWidget {
  @override
  _ManageTopicsScreenState createState() => _ManageTopicsScreenState();
}

class _ManageTopicsScreenState extends State<ManageTopicsScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  Topic? _editingTopic;

  // NOVO: Lista para armazenar os IDs das matérias selecionadas para o tópico atual
  List<int> _selectedSubjectIds = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // NOVO: Sobrescreve initState para pré-selecionar matérias ao editar
  @override
  void initState() {
    super.initState();
    // Se estiver editando um tópico, carrega os subjectIds existentes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_editingTopic != null) {
        setState(() {
          _selectedSubjectIds = List.from(_editingTopic!.subjectIds);
        });
      }
    });
  }


  void _saveTopic() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('O nome do tópico não pode ser vazio!'))
      );
      return;
    }

    final topicProvider = Provider.of<TopicProvider>(context, listen: false);

    if (_editingTopic == null) {
      // Adicionar novo tópico
      topicProvider.addTopic(Topic(
        name: _nameController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        subjectIds: _selectedSubjectIds, // ATUALIZADO: Passa os IDs das matérias selecionadas
      ));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tópico cadastrado!')));
    } else {
      // Atualizar tópico existente
      topicProvider.updateTopic(_editingTopic!.copyWith(
        name: _nameController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        subjectIds: _selectedSubjectIds, // ATUALIZADO: Passa os IDs das matérias selecionadas
      ));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tópico atualizado!')));
      _editingTopic = null; // Limpa o estado de edição
    }

    _nameController.clear();
    _descriptionController.clear();
    _selectedSubjectIds = []; // Limpa as seleções após salvar
    FocusScope.of(context).unfocus(); // Fecha o teclado
  }

  void _editTopic(Topic topic) {
    setState(() {
      _editingTopic = topic;
      _nameController.text = topic.name;
      _descriptionController.text = topic.description ?? '';
      _selectedSubjectIds = List.from(topic.subjectIds); // Carrega as seleções existentes
    });
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, Topic topic) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir o tópico "${topic.name}"?'),
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
                Provider.of<TopicProvider>(context, listen: false).deleteTopic(topic.id!);
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tópico excluído!'))
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
    final topicProvider = Provider.of<TopicProvider>(context);
    final subjectProvider = Provider.of<SubjectProvider>(context); // NOVO: Acessa o SubjectProvider

    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciar Tópicos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome do Tópico (ex: Citologia Vegetal)', // Nome do tópico, não da matéria
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descrição (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            // NOVO: Seletor de Matérias
            Text('Selecione as Matérias Associadas:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subjectProvider.subjects.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Nenhuma matéria cadastrada. Cadastre matérias primeiro.', style: TextStyle(color: Colors.red)),
                  )
                : Wrap( // Usamos Wrap para que os chips quebrem a linha automaticamente
                    spacing: 8.0, // Espaçamento horizontal entre os chips
                    runSpacing: 4.0, // Espaçamento vertical entre as linhas de chips
                    children: subjectProvider.subjects.map((subject) {
                      final isSelected = _selectedSubjectIds.contains(subject.id);
                      return ChoiceChip(
                        label: Text(subject.name),
                        selected: isSelected,
                        selectedColor: Theme.of(context).primaryColor.withOpacity(0.7),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedSubjectIds.add(subject.id!);
                            } else {
                              _selectedSubjectIds.remove(subject.id!);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveTopic,
              child: Text(_editingTopic == null ? 'Cadastrar Tópico' : 'Atualizar Tópico'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            if (_editingTopic != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _editingTopic = null;
                      _nameController.clear();
                      _descriptionController.clear();
                      _selectedSubjectIds = []; // Limpa seleções ao cancelar edição
                    });
                  },
                  child: Text('Cancelar Edição'),
                ),
              ),
            SizedBox(height: 24),
            Text(
              'Tópicos Cadastrados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: topicProvider.topics.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhum tópico cadastrado ainda.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: topicProvider.topics.length,
                      itemBuilder: (context, index) {
                        final topic = topicProvider.topics[index];
                        // NOVO: Exibir matérias associadas ao tópico na lista
                        final List<Subject> associatedSubjects = topic.subjectIds
                            .map((id) => subjectProvider.getSubjectById(id))
                            .where((subject) => subject != null)
                            .cast<Subject>()
                            .toList();
                        String subjectsText = associatedSubjects.isNotEmpty
                            ? ' (${associatedSubjects.map((s) => s.name).join(', ')})'
                            : '';

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 2,
                          child: ListTile(
                            title: Text('${topic.name}$subjectsText'), // Exibe o nome do tópico e suas matérias
                            subtitle: topic.description != null && topic.description!.isNotEmpty
                                ? Text(topic.description!)
                                : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editTopic(topic),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _showDeleteConfirmationDialog(context, topic),
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