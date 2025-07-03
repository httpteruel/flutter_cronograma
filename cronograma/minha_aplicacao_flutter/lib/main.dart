// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minha_aplicacao_flutter/injector.dart';
import 'package:minha_aplicacao_flutter/presentation/viewmodels/auth/register_viewmodel.dart';
import 'package:minha_aplicacao_flutter/presentation/viewmodels/project/project_list_viewmodel.dart';
import 'package:minha_aplicacao_flutter/presentation/viewmodels/project/project_form_viewmodel.dart';
import 'package:minha_aplicacao_flutter/presentation/viewmodels/task/task_list_viewmodel.dart';
import 'package:minha_aplicacao_flutter/presentation/viewmodels/task/task_form_viewmodel.dart';
import 'package:minha_aplicacao_flutter/presentation/viewmodels/project/project_users_viewmodel.dart';

import 'package:minha_aplicacao_flutter/presentation/views/auth/register/register_view.dart';
import 'package:minha_aplicacao_flutter/presentation/views/home/home_view.dart'; // Tela principal
import 'package:minha_aplicacao_flutter/presentation/views/project/project_list_view.dart';
import 'package:minha_aplicacao_flutter/presentation/views/project/project_form_view.dart';
import 'package:minha_aplicacao_flutter/presentation/views/task/task_list_view.dart';
import 'package:minha_aplicacao_flutter/presentation/views/task/task_form_view.dart';
import 'package:minha_aplicacao_flutter/presentation/views/project/project_users_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator(); // Inicializa o GetIt

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provedores para ViewModels
        ChangeNotifierProvider(
          create: (_) => serviceLocator<RegisterViewModel>(),
        ),
        ChangeNotifierProvider(
          create: (_) => serviceLocator<ProjectListViewModel>(),
        ),
        ChangeNotifierProvider(
          create: (_) => serviceLocator<ProjectFormViewModel>(),
        ),
        ChangeNotifierProvider(
          create: (_) => serviceLocator<TaskListViewModel>(),
        ),
        ChangeNotifierProvider(
          create: (_) => serviceLocator<TaskFormViewModel>(),
        ),
        ChangeNotifierProvider(
          create: (_) => serviceLocator<ProjectUsersViewModel>(),
        ),
        // Adicione outros ViewModels aqui conforme necessário
      ],
      child: MaterialApp(
        title: 'Gerenciador de Tarefas',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/', // Rota inicial
        routes: {
          '/': (context) =>
              const RegisterView(), // Tela de registro como inicial
          '/home': (context) => const HomeView(),
          '/projects': (context) => const ProjectListView(),
          '/add-project': (context) => const ProjectFormView(),
          '/tasks': (context) => const TaskListView(),
          '/add-task': (context) => const TaskFormView(),
          '/project-users': (context) => const ProjectUsersView(),
        },
      ),
    );
  }
}
