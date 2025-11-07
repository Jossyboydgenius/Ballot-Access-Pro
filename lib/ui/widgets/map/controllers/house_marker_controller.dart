import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ballot_access_pro/models/territory_houses.dart';
import 'package:ballot_access_pro/services/map_service.dart';

class HouseMarkerController {
  Set<Marker> houseMarkers = {};
  Set<Marker> filteredHouseMarkers = {};
  TerritoryHouses? houses;
  String selectedStatus = '';

  // Callback to be called when house markers state changes
  final Function() onStateChanged;
  // Callback for when a house is tapped
  final Function(HouseVisit) onHouseTapped;

  HouseMarkerController({
    required this.onStateChanged,
    required this.onHouseTapped,
  });

  Future<void> fetchHouses() async {
    debugPrint('Fetching house visits using offline-first approach');
    try {
      final housesData = await MapService.getHousesOfflineFirst();

      if (housesData != null) {
        debugPrint('Successfully fetched ${housesData.docs.length} houses');

        // Store the houses data
        houses = housesData;

        houseMarkers = housesData.docs.map((house) {
          debugPrint(
              'Creating marker for house: ${house.address} with status ${house.status}');
          return Marker(
            markerId: MarkerId('house_${house.id}'),
            position: LatLng(house.lat, house.long),
            icon: MapService.getMarkerIconForStatus(house.status),
            infoWindow: InfoWindow(
              title: house.address,
              // snippet: '${house.registeredVoters} registered voters',
        snippet: 'House Visit',
            ),
            onTap: () => onHouseTapped(house),
          );
        }).toSet();

        // Initialize filtered markers with all house markers
        filteredHouseMarkers = houseMarkers;

        onStateChanged();
      } else {
        debugPrint('No houses data received');
      }
    } catch (e) {
      debugPrint('Error fetching houses: $e');
    }
  }

  void onStatusChanged(String status, GoogleMapController? mapController) {
    selectedStatus = status;
    filterMarkersByStatus(mapController);
    onStateChanged();
  }

  void filterMarkersByStatus(GoogleMapController? mapController) {
    if (selectedStatus.isEmpty) {
      filteredHouseMarkers = houseMarkers;
    } else {
      filteredHouseMarkers = houseMarkers.where((marker) {
        final String houseId = marker.markerId.value.replaceAll('house_', '');
        final house = findHouseById(houseId);

        if (house == null) return false;

        // Normalize statuses for comparison
        final normalizedHouseStatus =
            normalizeStatusForComparison(house.status);
        final normalizedSelectedStatus =
            normalizeStatusForComparison(selectedStatus);

        return normalizedHouseStatus == normalizedSelectedStatus;
      }).toSet();

      if (filteredHouseMarkers.isNotEmpty && mapController != null) {
        final bounds = calculateBounds(filteredHouseMarkers);
        mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50.0));
      }
    }

    onStateChanged();
  }

  // Helper method to normalize status strings for comparison
  String normalizeStatusForComparison(String status) {
    final normalized = status.toLowerCase().trim();

    // Map UI display statuses to API statuses and vice versa
    if (normalized == 'not home') return 'nothome';
    if (normalized == 'nothome') return 'nothome';
    if (normalized == 'come back') return 'comeback';
    if (normalized == 'comeback') return 'comeback';
    if (normalized == 'not signed') return 'not-signed';
    if (normalized == 'not safe') return 'not-safe';
    if (normalized == 'not-safe') return 'not-safe';
    if (normalized == 'gated') return 'gated';
    if (normalized == 'not-signed') return 'not-signed';
    if (normalized == 'signed') return 'signed';

    return normalized; // Return original if no match found
  }

  HouseVisit? findHouseById(String id) {
    if (houses == null) return null;

    for (final house in houses!.docs) {
      if (house.id == id) {
        return house;
      }
    }
    return null;
  }

  LatLngBounds calculateBounds(Set<Marker> markers) {
    if (markers.isEmpty) {
      return LatLngBounds(
        southwest: const LatLng(40.70, -74.02),
        northeast: const LatLng(40.73, -73.98),
      );
    }

    double? minLat, maxLat, minLng, maxLng;

    for (final marker in markers) {
      final lat = marker.position.latitude;
      final lng = marker.position.longitude;

      minLat = minLat == null ? lat : min(minLat, lat);
      maxLat = maxLat == null ? lat : max(maxLat, lat);
      minLng = minLng == null ? lng : min(minLng, lng);
      maxLng = maxLng == null ? lng : max(maxLng, lng);
    }

    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }

  void navigateToHouse(HouseVisit house, GoogleMapController? mapController) {
    if (mapController == null) return;

    // Animate to the house's position
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(house.lat, house.long),
          zoom: 18.0,
        ),
      ),
    );

    // After a short delay, trigger the house tap action
    Future.delayed(const Duration(milliseconds: 500), () {
      onHouseTapped(house);
    });
  }
}
