// lib/api/services/task_api_service.dart

import 'package:dio/dio.dart';
import 'package:minha_aplicacao_flutter/api/api_constants.dart';
import 'package:minha_aplicacao_flutter/api/models/api_response.dart';
import 'package:minha_aplicacao_flutter/api/models/task_model.dart';

class TaskApiService {
  final Dio _dio;

  TaskApiService(this._dio);

  Future<ApiResponse<TaskModel>> createTask(TaskModel task) async {
    try {
      final response = await _dio.post(
        ApiConstants.tasksEndpoint,
        data: task.toJson(),
      );
      return ApiResponse.fromJson(
        response.data,
        (json) => TaskModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _handleDioError<TaskModel>(e);
    } catch (e) {
      return ApiResponse(
          success: false, message: 'An unexpected error occurred: $e');
    }
  }

  Future<ApiResponse<List<TaskModel>>> getTasksByProjectId(
      String projectId) async {
    try {
      final response = await _dio.get(
        ApiConstants.tasksByProjectIdEndpoint(projectId),
      );
      return ApiResponse.fromJsonList(
        response.data,
        (json) => TaskModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _handleDioError<List<TaskModel>>(e);
    } catch (e) {
      return ApiResponse(
          success: false, message: 'An unexpected error occurred: $e');
    }
  }

  Future<ApiResponse<TaskModel>> updateTaskStatus(
      String taskId, TaskStatus status) async {
    try {
      final response = await _dio.put(
        ApiConstants.taskByIdEndpoint(taskId),
        data: {'status': status.toString().split('.').last},
      );
      return ApiResponse.fromJson(
        response.data,
        (json) => TaskModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _handleDioError<TaskModel>(e);
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
