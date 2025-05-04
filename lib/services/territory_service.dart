import 'package:ballot_access_pro/models/territory.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ballot_access_pro/services/api/api.dart';
import 'package:ballot_access_pro/core/locator.dart';

class TerritoryService {
  static final Api _api = locator<Api>();

  static Future<List<Territory>> getTerritories() async {
    try {
      final response = await _api.getData('/territory/territories');
      if (response.isSuccessful && response.data != null) {
        final List<dynamic> territories = response.data['data'];
        return territories.map((json) => Territory.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching territories: $e');
      return [];
    }
  }

  static Set<Polygon> createTerritoryPolygons(List<Territory> territories) {
    return territories
        .where((territory) =>
            territory.boundary?.type == 'polygon' &&
            territory.boundary!.paths.isNotEmpty)
        .map((territory) {
      return Polygon(
        polygonId: PolygonId(territory.id),
        points: territory.boundary!.paths
            .map((point) => LatLng(point.lat, point.lng))
            .toList(),
        strokeWidth: 2,
        strokeColor: Colors.blue,
        fillColor: Colors.blue.withOpacity(0.1),
      );
    }).toSet();
  }

  static Set<Polyline> createTerritoryPolylines(List<Territory> territories) {
    return territories
        .where((territory) =>
            territory.boundary?.type == 'polyline' &&
            territory.boundary!.paths.isNotEmpty)
        .map((territory) {
      return Polyline(
        polylineId: PolylineId(territory.id),
        points: territory.boundary!.paths
            .map((point) => LatLng(point.lat, point.lng))
            .toList(),
        width: 2,
        color: Colors.red,
      );
    }).toSet();
  }

  static Future<String?> getCurrentTerritory() async {
    try {
      final response = await _api.getData('/petitioner');
      if (response.isSuccessful && response.data != null) {
        // Assuming the response includes the current territory ID
        // Adjust this based on your actual API response structure
        final territories = response.data['data']['territories'] as List;
        if (territories.isNotEmpty) {
          return territories[0]; // Get the first assigned territory
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching current territory: $e');
      return null;
    }
  }
}
