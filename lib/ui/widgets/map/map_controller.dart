import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ballot_access_pro/services/map_service.dart';
import 'package:ballot_access_pro/shared/utils/debug_utils.dart';

class MapController {
  GoogleMapController? mapController;
  bool isMapCreated = false;
  bool isLoading = true;
  MapType currentMapType = MapType.normal;
  bool animatingToCurrentLocation = false;
  bool userInteractedWithMap = false;

  // Callback to be called when map state changes
  final Function() onStateChanged;

  MapController({required this.onStateChanged});

  void dispose() {
    if (mapController != null) {
      mapController!.dispose();
      mapController = null;
    }
  }

  Future<void> onMapCreated(GoogleMapController controller,
      BuildContext context, Position? currentPosition) async {
    debugPrint('Map created!');
    if (isMapCreated) return;

    mapController = controller;
    isMapCreated = true;
    isLoading = false;
    onStateChanged();

    try {
      // First try loading map style from file
      String style;
      try {
        style = await DefaultAssetBundle.of(context)
            .loadString('assets/map_style.json');
        debugPrint('Loaded map style from assets file');
      } catch (e) {
        // If file loading fails, use a minimal style that ensures visibility
        style = jsonEncode([
          {
            "featureType": "all",
            "elementType": "all",
            "stylers": [
              {"visibility": "on"}
            ]
          }
        ]);
        debugPrint('Using fallback minimal map style: $e');
      }

      // Apply the style
      try {
        await controller.setMapStyle(style);
        debugPrint('Map style applied successfully');
      } catch (e) {
        debugPrint('Failed to apply map style: $e');
      }
    } catch (e) {
      debugPrint('Error setting map style: $e');
    }

    // Force the map to reload tiles
    if (currentPosition != null) {
      controller.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(currentPosition.latitude, currentPosition.longitude), 15));
      debugPrint(
          'Animated to current position: ${currentPosition.latitude}, ${currentPosition.longitude}');
    } else {
      debugPrint('No current position available for initial camera animation');
    }

    // Force an additional rebuild to ensure all UI elements are shown
    Future.delayed(const Duration(milliseconds: 300), () {
      onStateChanged();
    });
  }

  void animateToCurrentLocation(Position? currentPosition) {
    if (mapController == null || currentPosition == null) return;

    animatingToCurrentLocation = true;
    mapController!
        .animateCamera(
      CameraUpdate.newCameraPosition(
        MapService.getCameraPosition(currentPosition),
      ),
    )
        .then((_) {
      animatingToCurrentLocation = false;
      userInteractedWithMap = false;
      onStateChanged();
    });
  }

  void onCameraMove(CameraPosition position, bool isTrackingEnabled) {
    if (isTrackingEnabled && !animatingToCurrentLocation) {
      userInteractedWithMap = true;
      onStateChanged();
    }
  }

  void onMapTypeChanged(MapType mapType) {
    debugPrint('Changing map type to: $mapType');
    currentMapType = mapType;

    // If changing to satellite, use hybrid for better visibility
    if (mapType == MapType.satellite) {
      currentMapType = MapType.hybrid;
    }

    onStateChanged();
  }
}
