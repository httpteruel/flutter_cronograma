// lib/api/services/project_api_service.dart

import 'package:dio/dio.dart';
import 'package:minha_aplicacao_flutter/api/api_constants.dart';
import 'package:minha_aplicacao_flutter/api/models/api_response.dart';
import 'package:minha_aplicacao_flutter/api/models/project_model.dart';

class ProjectApiService {
  final Dio _dio;

  ProjectApiService(this._dio);

  Future<ApiResponse<ProjectModel>> createProject(ProjectModel project) async {
    try {
      final response = await _dio.post(
        ApiConstants.projectsEndpoint,
        data: project.toJson(),
      );
      return ApiResponse.fromJson(
        response.data,
        (json) => ProjectModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _handleDioError<ProjectModel>(e);
    } catch (e) {
      return ApiResponse(
          success: false, message: 'An unexpected error occurred: $e');
    }
  }

  Future<ApiResponse<List<ProjectModel>>> getAllProjects() async {
    try {
      final response = await _dio.get(ApiConstants.projectsEndpoint);
      return ApiResponse.fromJsonList(
        response.data,
        (json) => ProjectModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _handleDioError<List<ProjectModel>>(e);
    } catch (e) {
      return ApiResponse(
          success: false, message: 'An unexpected error occurred: $e');
    }
  }

  Future<ApiResponse<ProjectModel>> addUsersToProject(
      String projectId, List<String> userIds) async {
    try {
      final response = await _dio.post(
        ApiConstants.addUsersToProjectEndpoint(projectId),
        data: {'userIds': userIds},
      );
      return ApiResponse.fromJson(
        response.data,
        (json) => ProjectModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _handleDioError<ProjectModel>(e);
    } catch (e) {
      return ApiResponse(
          success: false, message: 'An unexpected error occurred: $e');
    }
  }

  ApiResponse<T> _handleDioError<T>(DioException e) {
    if (e.response != null) {
      return ApiResponse(
        success: false,
        message: e.response!.data['message'] ?? 'Server error',
        statusCode: e.response!.statusCode,
      );
    } else {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.message}',
      );
    }
  }
}
