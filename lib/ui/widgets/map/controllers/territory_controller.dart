import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ballot_access_pro/services/territory_service.dart';
import 'package:ballot_access_pro/services/petitioner_service.dart';

class TerritoryController {
  Set<Polygon> territoryPolygons = {};
  Set<Polyline> territoryPolylines = {};

  // Callback to be called when territory state changes
  final Function() onStateChanged;

  TerritoryController({required this.onStateChanged});

  Future<void> fetchTerritories() async {
    try {
      debugPrint('Fetching territories from API');
      final territories = await TerritoryService.getTerritories();

      if (territories.isEmpty) {
        debugPrint('No territories found');
        return;
      }

      debugPrint('Successfully fetched ${territories.length} territories');

      // Get the petitioner's assigned territory ID
      final assignedTerritoryId =
          await PetitionerService().getAssignedTerritoryId();
      debugPrint('Assigned territory ID: $assignedTerritoryId');

      // Create polygons for areas with a closed shape (polygon type)
      territoryPolygons = territories
          .where((territory) =>
              territory.boundary?.type == 'polygon' &&
              territory.boundary!.paths.isNotEmpty)
          .map((territory) {
        debugPrint('Creating polygon for territory: ${territory.name}');

        // Highlight the assigned territory with a different color
        final bool isAssigned = territory.id == assignedTerritoryId;
        final Color strokeColor = isAssigned ? Colors.green : Colors.red;
        final Color fillColor = isAssigned
            ? Colors.green.withOpacity(0.4)
            : Colors.red.withOpacity(0.2);

        return Polygon(
          polygonId: PolygonId(territory.id),
          points: territory.boundary!.paths
              .map((point) => LatLng(point.lat, point.lng))
              .toList(),
          strokeWidth:
              isAssigned ? 3 : 2, // Make assigned territory border thicker
          strokeColor: strokeColor,
          fillColor: fillColor,
        );
      }).toSet();

      // Create polylines for paths (polyline type)
      territoryPolylines = territories
          .where((territory) =>
              territory.boundary?.type == 'polyline' &&
              territory.boundary!.paths.isNotEmpty)
          .map((territory) {
        debugPrint('Creating polyline for territory: ${territory.name}');

        // Highlight the assigned territory with a different color
        final bool isAssigned = territory.id == assignedTerritoryId;
        final Color lineColor = isAssigned ? Colors.green : Colors.red;

        return Polyline(
          polylineId: PolylineId(territory.id),
          points: territory.boundary!.paths
              .map((point) => LatLng(point.lat, point.lng))
              .toList(),
          width: isAssigned ? 4 : 3, // Make assigned territory line thicker
          color: lineColor,
        );
      }).toSet();

      debugPrint(
          'Created ${territoryPolygons.length} polygons and ${territoryPolylines.length} polylines');

      onStateChanged();
    } catch (e) {
      debugPrint('Error fetching territories: $e');
    }
  }
}
