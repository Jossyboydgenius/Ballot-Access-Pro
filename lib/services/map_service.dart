import 'package:ballot_access_pro/services/local_storage_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:ballot_access_pro/models/territory_houses.dart';
import 'package:ballot_access_pro/services/api/api.dart';
import 'package:ballot_access_pro/core/locator.dart';
import 'package:ballot_access_pro/services/sync_service.dart';
import 'package:ballot_access_pro/services/database_service.dart';
import 'package:flutter/foundation.dart';

class MapService {
  static final Api _api = locator<Api>();

  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  static Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.street}, ${place.subLocality}, ${place.locality}';
      }
      return '$latitude, $longitude';
    } catch (e) {
      return '$latitude, $longitude';
    }
  }

  static CameraPosition getCameraPosition(Position position) {
    return CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 15,
    );
  }

  static Marker createPetitionerMarker(
      String id, LatLng position, String name) {
    return Marker(
      markerId: MarkerId('petitioner_$id'),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(
        title: name,
        snippet: 'Petitioner',
      ),
    );
  }

  static Marker createVoterMarker(String id, LatLng position, String status) {
    return Marker(
      markerId: MarkerId('voter_$id'),
      position: position,
      icon: getMarkerIconForStatus(status),
      infoWindow: InfoWindow(
        title: 'Voter',
        snippet: status,
      ),
    );
  }

  static final mapStyle = [
    {
      "featureType": "poi",
      "elementType": "labels",
      "stylers": [
        {"visibility": "on"}
      ]
    },
    {
      "featureType": "transit",
      "elementType": "labels",
      "stylers": [
        {"visibility": "on"}
      ]
    },
    {
      "featureType": "road",
      "elementType": "labels",
      "stylers": [
        {"visibility": "on"}
      ]
    }
  ];

  static Future<TerritoryHouses?> getHousesForTerritory() async {
    debugPrint('MapService: Fetching house visits');
    try {
      final response = await _api.getData('/petitioner/house');
      debugPrint('MapService: Raw API response: ${response.data}');

      if (response.isSuccessful && response.data != null) {
        final houses = TerritoryHouses.fromJson(response.data['data']);
        debugPrint(
            'MapService: Successfully parsed ${houses.docs.length} houses');
        return houses;
      }
      debugPrint('MapService: Failed to fetch houses - ${response.message}');
      return null;
    } catch (e, stackTrace) {
      debugPrint('MapService: Error fetching houses: $e');
      debugPrint('MapService: Stack trace: $stackTrace');
      return null;
    }
  }

  // Offline-first method to get houses
  static Future<TerritoryHouses?> getHousesOfflineFirst() async {
    final syncService = locator<SyncService>();

    try {
      // First try to get from local database
      final localHouses = await DatabaseService.getHouses();

      // If we have cached data and are offline, return local data
      if (localHouses.isNotEmpty && !await syncService.isOnline()) {
        debugPrint(
            'MapService: Returning ${localHouses.length} cached houses (offline)');
        return _convertHousesToTerritoryHouses(localHouses);
      }

      // If we're online, try to fetch fresh data
      if (await syncService.isOnline()) {
        try {
          final freshHouses = await getHousesForTerritory();
          if (freshHouses != null) {
            // Cache the fresh data
            await _cacheHouses(freshHouses.docs);
            debugPrint(
                'MapService: Fetched ${freshHouses.docs.length} fresh houses');
            return freshHouses;
          }
        } catch (e) {
          debugPrint('MapService: Failed to fetch fresh data: $e');
          // Fall back to cached data if available
          if (localHouses.isNotEmpty) {
            debugPrint(
                'MapService: Falling back to ${localHouses.length} cached houses');
            return _convertHousesToTerritoryHouses(localHouses);
          }
        }
      }

      // Return cached data if available
      if (localHouses.isNotEmpty) {
        return _convertHousesToTerritoryHouses(localHouses);
      }

      return null;
    } catch (e) {
      debugPrint('MapService: Error getting houses offline-first: $e');
      return null;
    }
  }

  // Helper method to convert list of houses to TerritoryHouses
  static TerritoryHouses _convertHousesToTerritoryHouses(
      List<HouseVisit> houses) {
    return TerritoryHouses(
      docs: houses,
      totalDocs: houses.length,
      limit: houses.length,
      totalPages: 1,
      page: 1,
      pagingCounter: 1,
      hasPrevPage: false,
      hasNextPage: false,
      prevPage: null,
      nextPage: null,
    );
  }

  // Helper method to cache houses
  static Future<void> _cacheHouses(List<HouseVisit> houses) async {
    try {
      for (final house in houses) {
        await DatabaseService.insertHouse(house);
      }
    } catch (e) {
      debugPrint('MapService: Error caching houses: $e');
    }
  }

  static Future<bool> addHouseVisit({
    required double lat,
    required double long,
    required String address,
    required String territory,
    required String status,
    required int registeredVoters,
    required String note,
  }) async {
    debugPrint('MapService: Adding new house visit');
    try {
      // Get petitioner ID from local storage
      final petitionerId = await locator<LocalStorageService>()
          .getStorageValue(LocalStorageKeys.userId);

      if (petitionerId == null) {
        debugPrint('MapService: No petitioner ID found');
        return false;
      }

      // Get current location for petitioner coordinates
      Position? currentPosition;
      try {
        currentPosition = await getCurrentLocation();
      } catch (e) {
        debugPrint(
            'MapService: Could not get current location for petitioner: $e');
        // Still proceed with the request, but without petitioner coordinates
      }

      // Convert status to the format expected by the API
      String formattedStatus = _formatStatusForApi(status);

      final Map<String, dynamic> requestBody = {
        'lat': lat.toString(),
        'long': long.toString(),
        'address': address,
        'territory': territory,
        'status': formattedStatus,
        'registeredVoters': registeredVoters,
        'note': note,
        'petitioner': {
          'id': petitionerId,
          if (currentPosition != null) ...{
            'lat': currentPosition.latitude,
            'long': currentPosition.longitude,
          }
        },
      };

      debugPrint('MapService: Request body: $requestBody');

      final response = await _api.postData(
        '/house-visit/add-house',
        requestBody,
        hasHeader: true,
      );

      if (response.isSuccessful) {
        debugPrint('MapService: Successfully added house visit');
        return true;
      }

      debugPrint('MapService: Failed to add house visit - ${response.message}');
      return false;
    } catch (e, stackTrace) {
      debugPrint('MapService: Error adding house visit: $e');
      debugPrint('MapService: Stack trace: $stackTrace');
      return false;
    }
  }

  // Offline-first method to add house visit
  static Future<bool> addHouseVisitOfflineFirst({
    required double lat,
    required double long,
    required String address,
    required String territory,
    required String status,
    required int registeredVoters,
    required String note,
  }) async {
    final syncService = locator<SyncService>();

    try {
      // Check if we're online
      if (await syncService.isOnline()) {
        // Try to add online first
        final success = await addHouseVisit(
          lat: lat,
          long: long,
          address: address,
          territory: territory,
          status: status,
          registeredVoters: registeredVoters,
          note: note,
        );

        if (success) {
          return true;
        }
      }

      // Add offline if online failed or we're offline
      final houseData = {
        'latitude': lat,
        'longitude': long,
        'address': address,
        'territory': territory,
        'status': status,
        'registered_voters': registeredVoters,
        'notes': note,
        'petitioner_id': await locator<LocalStorageService>()
                .getStorageValue(LocalStorageKeys.userId) ??
            'unknown',
      };

      await syncService.addHouseOffline(houseData);
      debugPrint('MapService: Added house visit offline');
      return true;
    } catch (e) {
      debugPrint('MapService: Error adding house visit offline-first: $e');
      return false;
    }
  }

  static Future<bool> updateHouseStatus({
    required String markerId,
    required String status,
    Map<String, String>? lead,
  }) async {
    debugPrint('MapService: Updating house status');
    try {
      // The API has strict requirements for status values
      // Make sure we're using exactly the format the API expects
      final String apiFormattedStatus = _normalizeStatusForAPI(status);

      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        'marker': markerId,
        'status': apiFormattedStatus,
      };

      // Add lead data if provided
      if (lead != null && lead.isNotEmpty) {
        // Validate email format if present
        if (lead.containsKey('email') && lead['email']!.isNotEmpty) {
          if (!_isValidEmail(lead['email']!)) {
            debugPrint('MapService: Invalid email format in lead data');
            return false;
          }
        }

        requestBody['lead'] = lead;
      }

      debugPrint('MapService: Sending update request with body: $requestBody');

      // Make the API call
      final response = await _api.putData(
        '/house-visit/update-status',
        requestBody,
        hasHeader: true,
      );

      if (response.isSuccessful) {
        debugPrint('MapService: Successfully updated house status');
        return true;
      }

      debugPrint(
          'MapService: Failed to update house status - ${response.message}');
      return false;
    } catch (e, stackTrace) {
      debugPrint('MapService: Error updating house status: $e');
      debugPrint('MapService: Stack trace: $stackTrace');
      return false;
    }
  }

  // Offline-first method to update house status
  static Future<bool> updateHouseStatusOfflineFirst({
    required String markerId,
    required String status,
    Map<String, String>? lead,
  }) async {
    final syncService = locator<SyncService>();

    try {
      // Check if we're online
      if (await syncService.isOnline()) {
        // Try to update online first
        final success = await updateHouseStatus(
          markerId: markerId,
          status: status,
          lead: lead,
        );

        if (success) {
          return true;
        }
      }

      // Update offline if online failed or we're offline
      final updateData = {
        'status': status,
        'lead_data': lead,
      };

      await syncService.updateHouseOffline(markerId, updateData);
      debugPrint('MapService: Updated house status offline');
      return true;
    } catch (e) {
      debugPrint('MapService: Error updating house status offline-first: $e');
      return false;
    }
  }

  // Helper method to get marker icon for status
  static BitmapDescriptor getMarkerIconForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'signed':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'partially-signed':
        return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueYellow);
      case 'comeback':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case 'nothome':
      case 'not home':
        return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange);
      case 'bas':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }

  // Helper method to format status for API
  static String _formatStatusForApi(String status) {
    final normalized = status.toLowerCase().trim();

    switch (normalized) {
      case 'not home':
        return 'notHome';
      case 'come back':
        return 'comeback';
      case 'partially signed':
        return 'partially-signed';
      case 'signed':
        return 'signed';
      case 'bas':
        return 'bas';
      default:
        return normalized;
    }
  }

  // Helper method to normalize status for API
  static String _normalizeStatusForAPI(String status) {
    final normalized = status.toLowerCase().trim();

    switch (normalized) {
      case 'not home':
      case 'nothome':
        return 'notHome';
      case 'come back':
      case 'comeback':
        return 'comeback';
      case 'partially signed':
      case 'partially-signed':
        return 'partially-signed';
      case 'signed':
        return 'signed';
      case 'bas':
        return 'bas';
      default:
        return normalized;
    }
  }

  // Helper method to validate email
  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }
}
