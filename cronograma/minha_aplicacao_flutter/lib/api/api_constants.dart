// lib/api/api_constants.dart

class ApiConstants {
  static const String baseUrl =
      'http://localhost:3000/api'; // Certifique-se que esta é a URL correta!

  // Endpoints de Autenticação
  static const String registerEndpoint = '/users'; // POST para criar usuário

  // Endpoints de Usuários
  static const String usersEndpoint = '/users'; // GET para todos os usuários

  // Endpoints de Projetos
  static const String projectsEndpoint =
      '/projects'; // GET para todos, POST para criar
  static String projectByIdEndpoint(String id) =>
      '/projects/$id'; // GET por ID, PUT/DELETE
  static String addUsersToProjectEndpoint(String projectId) =>
      '/projects/$projectId/users'; // POST para associar N:N

  // Endpoints de Tarefas
  static const String tasksEndpoint =
      '/tasks'; // GET para todas, POST para criar
  static String taskByIdEndpoint(String id) =>
      '/tasks/$id'; // GET por ID, PUT/DELETE
  static String tasksByProjectIdEndpoint(String projectId) =>
      '/projects/$projectId/tasks'; // GET tarefas de um projeto
}
