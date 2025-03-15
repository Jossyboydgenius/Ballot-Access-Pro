class ApiResponse {
  final dynamic data;
  final bool isSuccessful;
  final String message;
  int? code;

  ApiResponse({
    this.data,
    required this.isSuccessful,
    required this.message,
    this.code,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      data: json['data'],
      isSuccessful: json['success'] ?? false,
      message: json['message'] ?? 'Unknown error occurred',
      code: json['code'],
    );
  }

  factory ApiResponse.timeout() {
    return ApiResponse(
      data: null,
      isSuccessful: false,
      message: 'Request timed out',
    );
  }

  factory ApiResponse.unknownError(int? statusCode) {
    return ApiResponse(
      data: null,
      isSuccessful: false,
      message: 'An unknown error occurred',
      code: statusCode,
    );
  }
} 