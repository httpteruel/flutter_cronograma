// lib/injector.dart

import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

// API Services
import 'package:minha_aplicacao_flutter/api/services/user_api_service.dart';
import 'package:minha_aplicacao_flutter/api/services/project_api_service.dart';
import 'package:minha_aplicacao_flutter/api/services/task_api_service.dart';

// Data Sources (exemplo, ainda não implementados)
import 'package:minha_aplicacao_flutter/data/datasources/user_remote_datasource.dart';
import 'package:minha_aplicacao_flutter/data/datasources/project_remote_datasource.dart';
import 'package:minha_aplicacao_flutter/data/datasources/task_remote_datasource.dart';

// Repositories (implementações concretas)
import 'package:minha_aplicacao_flutter/data/impl/user_repository_impl.dart';
import 'package:minha_aplicacao_flutter/data/impl/project_repository_impl.dart';
import 'package:minha_aplicacao_flutter/data/impl/task_repository_impl.dart';

// Repositories (contratos - interfaces)
import 'package:minha_aplicacao_flutter/domain/repositories/user_repository.dart';
import 'package:minha_aplicacao_flutter/domain/repositories/project_repository.dart';
import 'package:minha_aplicacao_flutter/domain/repositories/task_repository.dart';

// Use Cases
import 'package:minha_aplicacao_flutter/domain/usecases/auth/register_user_usecase.dart';
import 'package:minha_aplicacao_flutter/domain/usecases/project/create_project_usecase.dart';
import 'package:minha_aplicacao_flutter/domain/usecases/task/create_task_usecase.dart';
import 'package:minha_aplicacao_flutter/domain/usecases/project/add_user_to_project_usecase.dart';
import 'package:minha_aplicacao_flutter/domain/usecases/project/get_all_projects_usecase.dart';
import 'package:minha_aplicacao_flutter/domain/usecases/task/get_tasks_by_project_usecase.dart';
import 'package:minha_aplicacao_flutter/domain/usecases/user/get_all_users_usecase.dart';

// ViewModels
import 'package:minha_aplicacao_flutter/presentation/viewmodels/auth/register_viewmodel.dart';
import 'package:minha_aplicacao_flutter/presentation/viewmodels/project/project_list_viewmodel.dart';
import 'package:minha_aplicacao_flutter/presentation/viewmodels/project/project_form_viewmodel.dart';
import 'package:minha_aplicacao_flutter/presentation/viewmodels/task/task_list_viewmodel.dart';
import 'package:minha_aplicacao_flutter/presentation/viewmodels/task/task_form_viewmodel.dart';
import 'package:minha_aplicacao_flutter/presentation/viewmodels/project/project_users_viewmodel.dart'; // Para N:N

final GetIt serviceLocator = GetIt.instance;

Future<void> setupServiceLocator() async {
  // ------------------------------
  // Core / Infraestrutura
  // ------------------------------

  // Dio - Cliente HTTP
  serviceLocator.registerLazySingleton<Dio>(() => Dio(
        BaseOptions(
          baseUrl:
              'http://localhost:3000/api/', // **IMPORTANTE: Substitua pela URL da sua API**
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 3),
          headers: {'Content-Type': 'application/json'},
        ),
      ));

  // Shared Preferences (para persistência local simples)
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
  serviceLocator
      .registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Flutter Local Notifications
  serviceLocator.registerLazySingleton<FlutterLocalNotificationsPlugin>(
    () => FlutterLocalNotificationsPlugin(),
  );

  // ------------------------------
  // API Services
  // ------------------------------
  serviceLocator.registerLazySingleton<UserApiService>(
    () => UserApiService(serviceLocator<Dio>()),
  );
  serviceLocator.registerLazySingleton<ProjectApiService>(
    () => ProjectApiService(serviceLocator<Dio>()),
  );
  serviceLocator.registerLazySingleton<TaskApiService>(
    () => TaskApiService(serviceLocator<Dio>()),
  );

  // ------------------------------
  // Data Sources
  // ------------------------------
  serviceLocator.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSource(serviceLocator<UserApiService>()),
  );
  serviceLocator.registerLazySingleton<ProjectRemoteDataSource>(
    () => ProjectRemoteDataSource(serviceLocator<ProjectApiService>()),
  );
  serviceLocator.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSource(serviceLocator<TaskApiService>()),
  );

  // ------------------------------
  // Repositories (Implementações)
  // ------------------------------
  serviceLocator.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(serviceLocator<UserRemoteDataSource>()),
  );
  serviceLocator.registerLazySingleton<ProjectRepository>(
    () => ProjectRepositoryImpl(serviceLocator<ProjectRemoteDataSource>()),
  );
  serviceLocator.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(serviceLocator<TaskRemoteDataSource>()),
  );

  // ------------------------------
  // Use Cases
  // ------------------------------
  // Auth
  serviceLocator.registerLazySingleton<RegisterUserUseCase>(
    () => RegisterUserUseCase(serviceLocator<UserRepository>()),
  );

  // Project
  serviceLocator.registerLazySingleton<CreateProjectUseCase>(
    () => CreateProjectUseCase(serviceLocator<ProjectRepository>()),
  );
  serviceLocator.registerLazySingleton<GetAllProjectsUseCase>(
    () => GetAllProjectsUseCase(serviceLocator<ProjectRepository>()),
  );
  serviceLocator.registerLazySingleton<AddUserToProjectUseCase>(
    () => AddUserToProjectUseCase(serviceLocator<ProjectRepository>()),
  );

  // Task
  serviceLocator.registerLazySingleton<CreateTaskUseCase>(
    () => CreateTaskUseCase(serviceLocator<TaskRepository>()),
  );
  serviceLocator.registerLazySingleton<GetTasksByProjectUseCase>(
    () => GetTasksByProjectUseCase(serviceLocator<TaskRepository>()),
  );

  // User
  serviceLocator.registerLazySingleton<GetAllUsersUseCase>(
    () => GetAllUsersUseCase(serviceLocator<UserRepository>()),
  );

  // ------------------------------
  // ViewModels
  // ------------------------------
  serviceLocator.registerFactory<RegisterViewModel>(
    () => RegisterViewModel(serviceLocator<RegisterUserUseCase>()),
  );
  serviceLocator.registerFactory<ProjectListViewModel>(
    () => ProjectListViewModel(serviceLocator<GetAllProjectsUseCase>()),
  );
  serviceLocator.registerFactory<ProjectFormViewModel>(
    () => ProjectFormViewModel(serviceLocator<CreateProjectUseCase>()),
  );
  serviceLocator.registerFactory<TaskListViewModel>(
    () => TaskListViewModel(serviceLocator<GetTasksByProjectUseCase>()),
  );
  serviceLocator.registerFactory<TaskFormViewModel>(
    () => TaskFormViewModel(serviceLocator<CreateTaskUseCase>()),
  );
  serviceLocator.registerFactory<ProjectUsersViewModel>(
    () => ProjectUsersViewModel(
      serviceLocator<GetAllUsersUseCase>(),
      serviceLocator<AddUserToProjectUseCase>(),
    ),
  );
}
