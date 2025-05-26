import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../models/api_response_model.dart';
import '../models/petitioner_model.dart';
import '../models/lead_model.dart';
import '../models/house_visit_model.dart';
import 'api/api.dart';

class PetitionerService {
  PetitionerService._privateConstructor();

  static final PetitionerService _instance =
      PetitionerService._privateConstructor();

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

  // Method to get the assigned territory for the petitioner
  Future<Territory?> getAssignedTerritory() async {
    final response = await getPetitionerProfile();

    if (!response.status || response.data == null) {
      debugPrint('Failed to get assigned territory: ${response.message}');
      return null;
    }

    return response.data!.assignedTerritory;
  }

  // Method to auto-fill territory data in forms
  Future<String> getAssignedTerritoryId() async {
    final territory = await getAssignedTerritory();
    return territory?.id ?? '';
  }

  // Method to get territory name for display purposes
  Future<String> getAssignedTerritoryName() async {
    final territory = await getAssignedTerritory();
    return territory?.name ?? 'No Territory';
  }

  // Method to get petitioner ID from profile
  Future<String?> getPetitionerId() async {
    final response = await getPetitionerProfile();

    if (!response.status || response.data == null) {
      debugPrint('Failed to get petitioner ID: ${response.message}');
      return null;
    }

    return response.data!.id;
  }
}
