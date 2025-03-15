import 'package:flutter/material.dart';
import '../core/locator.dart';
import 'api/api.dart';
import 'api/api_response.dart';

class AuthService {
  AuthService._privateConstructor();

  static final AuthService _instance = AuthService._privateConstructor();

  factory AuthService() {
    return _instance;
  }

  final Api _api = locator<Api>();

  Future<ApiResponse> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String address,
    required String password,
    required String gender,
    required String country,
  }) async {
    debugPrint('Registering user');
    final response = await _api.postData(
      '/petitioner/add',
      {
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'email': email,
        'address': address,
        'password': password,
        'gender': gender,
        'country': country,
      },
      hasHeader: false,
    );
    return response;
  }

  Future<ApiResponse> login({
    required String email,
    required String password,
  }) async {
    debugPrint('Logging in user');
    final response = await _api.postData(
      '/auth/login',
      {
        'email': email,
        'password': password,
      },
      hasHeader: false,
    );
    return response;
  }

  Future<ApiResponse> resendVerificationEmail({
    required String userId,
  }) async {
    debugPrint('Resending verification email');
    final response = await _api.postData(
      '/auth/resend-verification',
      {
        'id': userId,
      },
      hasHeader: true,
    );
    return response;
  }

  Future<ApiResponse> verifyEmail({
    required String code,
    required String userId,
  }) async {
    debugPrint('Verifying email');
    final response = await _api.postData(
      '/auth/verify-email',
      {
        'code': code,
        'id': userId,
      },
      hasHeader: true,
    );
    return response;
  }
} 