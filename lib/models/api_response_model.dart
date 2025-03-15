class ApiResponseModel<T> {
  final String message;
  final bool status;
  final int statusCode;
  final T? data;
  final String? error;

  ApiResponseModel({
    required this.message,
    required this.status,
    required this.statusCode,
    this.data,
    this.error,
  });

  factory ApiResponseModel.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return ApiResponseModel(
      message: json['message'] as String,
      status: json['status'] as bool,
      statusCode: json['statusCode'] as int,
      data: json['data'] != null ? fromJson(json['data'] as Map<String, dynamic>) : null,
      error: json['error'] as String?,
    );
  }
} 