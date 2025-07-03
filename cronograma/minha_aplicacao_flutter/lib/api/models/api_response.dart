// lib/api/models/api_response.dart

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(Object? json) fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      statusCode: json['statusCode'] as int?,
    );
  }

  factory ApiResponse.fromJsonList(
      Map<String, dynamic> json, T Function(Object? json) fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] != null
          ? (json['data'] as List<dynamic>)
              .map((item) => fromJsonT(item))
              .toList() as T // Assume T is List<SomeModel>
          : null,
      statusCode: json['statusCode'] as int?,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T? value) toJsonT) {
    return {
      'success': success,
      'message': message,
      'data': toJsonT(data),
      'statusCode': statusCode,
    };
  }
}
