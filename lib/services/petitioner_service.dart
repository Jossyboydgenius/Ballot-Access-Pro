import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../models/api_response_model.dart';
import '../models/petitioner_model.dart';
import '../models/lead_model.dart';
import '../models/house_visit_model.dart';
import 'api/api.dart';

class PetitionerService {
  PetitionerService._privateConstructor();

  static final PetitionerService _instance = PetitionerService._privateConstructor();

  factory PetitionerService() {
    return _instance;
  }

  final Api _api = locator<Api>();

  Future<ApiResponseModel<PetitionerModel>> getPetitionerProfile() async {
    debugPrint('Getting petitioner profile');
    final response = await _api.getData('/petitioner');
    
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
      (json) => PetitionerModel.fromJson(json),
    );
  }

  Future<ApiResponseModel<LeadResponse>> getLeads() async {
    debugPrint('Getting petitioner leads');
    final response = await _api.getData('/petitioner/leads');
    
    return ApiResponseModel.fromJson(
      response.data,
      (json) => LeadResponse.fromJson(json),
    );
  }

  Future<ApiResponseModel<HouseVisitResponse>> getHouseVisits() async {
    debugPrint('Getting house visits');
    final response = await _api.getData('/petitioner/house');
    
    return ApiResponseModel.fromJson(
      response.data,
      (json) => HouseVisitResponse.fromJson(json),
    );
  }
} 