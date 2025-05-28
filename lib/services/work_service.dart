import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../models/api_response_model.dart';
import '../models/work_session_model.dart';
import 'api/api.dart';
import 'package:geolocator/geolocator.dart';

class WorkService {
  WorkService._privateConstructor();

  static final WorkService _instance = WorkService._privateConstructor();

  factory WorkService() {
    return _instance;
  }

  final Api _api = locator<Api>();

  // Start a work session
  Future<ApiResponseModel<WorkSession>> startWork({
    required double longitude,
    required double latitude,
    String? address,
  }) async {
    debugPrint('Starting work session');
    final response = await _api.postData(
      '/work/start',
      {
        'long': longitude,
        'lat': latitude,
        if (address != null) 'address': address,
      },
      hasHeader: true,
    );

    if (!response.isSuccessful) {
      return ApiResponseModel(
        message: response.message,
        status: false,
        statusCode: response.code ?? 400,
        data: null,
        error: response.message,
      );
    }

    return ApiResponseModel.fromJson(
      response.data,
      (json) => WorkSession.fromJson(json),
    );
  }

  // End a work session
  Future<ApiResponseModel<WorkSession>> endWork({
    required double longitude,
    required double latitude,
    String? address,
  }) async {
    debugPrint('Ending work session');
    final response = await _api.postData(
      '/work/end',
      {
        'long': longitude,
        'lat': latitude,
        if (address != null) 'address': address,
      },
      hasHeader: true,
    );

    if (!response.isSuccessful) {
      return ApiResponseModel(
        message: response.message,
        status: false,
        statusCode: response.code ?? 400,
        data: null,
        error: response.message,
      );
    }

    return ApiResponseModel.fromJson(
      response.data,
      (json) => WorkSession.fromJson(json),
    );
  }

  // Get the active work session
  Future<ApiResponseModel<WorkSession?>> getActiveWorkSession() async {
    debugPrint('Fetching active work session');
    final response = await _api.getData(
      '/work/active',
      hasHeader: true,
    );

    if (!response.isSuccessful) {
      return ApiResponseModel(
        message: response.message,
        status: false,
        statusCode: response.code ?? 400,
        data: null,
        error: response.message,
      );
    }

    // Check if there's an active session
    if (response.data['data'] == null) {
      return ApiResponseModel(
        message: 'No active work session',
        status: true,
        statusCode: 200,
        data: null,
        error: null,
      );
    }

    return ApiResponseModel.fromJson(
      response.data,
      (json) => WorkSession.fromJson(json),
    );
  }

  // Get work session history
  Future<ApiResponseModel<WorkSessionResponse>> getWorkSessions(
      {int page = 1}) async {
    debugPrint('Fetching work sessions');
    final response = await _api.getData(
      '/work/sessions?page=$page',
      hasHeader: true,
    );

    if (!response.isSuccessful) {
      return ApiResponseModel(
        message: response.message,
        status: false,
        statusCode: response.code ?? 400,
        data: null,
        error: response.message,
      );
    }

    return ApiResponseModel.fromJson(
      response.data,
      (json) => WorkSessionResponse.fromJson(json),
    );
  }

  // Helper method to get current location
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }
}
