// lib/api/services/user_api_service.dart

import 'package:dio/dio.dart';
import 'package:minha_aplicacao_flutter/api/api_constants.dart';
import 'package:minha_aplicacao_flutter/api/models/api_response.dart';
import 'package:minha_aplicacao_flutter/api/models/user_model.dart';

class UserApiService {
  final Dio _dio;

  UserApiService(this._dio);

  Future<ApiResponse<UserModel>> registerUser(UserModel user) async {
    try {
      final response = await _dio.post(
        ApiConstants.registerEndpoint,
        data: user.toJson(),
      );
      return ApiResponse.fromJson(
        response.data,
        (json) => UserModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _handleDioError<UserModel>(e);
    } catch (e) {
      return ApiResponse(
          success: false, message: 'An unexpected error occurred: $e');
    }
  }

  Future<ApiResponse<List<UserModel>>> getAllUsers() async {
    try {
      final response = await _dio.get(ApiConstants.usersEndpoint);
      return ApiResponse.fromJsonList(
        response.data,
        (json) => UserModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _handleDioError<List<UserModel>>(e);
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
