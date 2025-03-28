import 'package:ballot_access_pro/services/local_storage_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:ballot_access_pro/models/territory_houses.dart';
import 'package:ballot_access_pro/services/api/api.dart';
import 'package:ballot_access_pro/core/locator.dart';
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

  static Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
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

  static Marker createPetitionerMarker(String id, LatLng position, String name) {
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
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
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
        {
          "visibility": "off"
        }
      ]
    },
    {
      "featureType": "transit",
      "elementType": "labels",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    },
    {
      "featureType": "road",
      "elementType": "labels",
      "stylers": [
        {
          "visibility": "on"
        }
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
        debugPrint('MapService: Successfully parsed ${houses.docs.length} houses');
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
      // Get petitioner ID from local storage or other source
      final token = await locator<LocalStorageService>().getStorageValue(LocalStorageKeys.accessToken);
      
      // Convert status to the format expected by the API
      String formattedStatus = _formatStatusForApi(status);
      
      final response = await _api.postData(
        '/house-visit/add-house',
        {
          'lat': lat.toString(),
          'long': long.toString(),
          'address': address,
          'territory': territory,
          'status': formattedStatus,
          'registeredVoters': registeredVoters,
          'petitioner': token, // Using token as petitioner ID for now
          'note': note,
        },
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

  // Helper method to convert UI status to API status format
  static String _formatStatusForApi(String status) {
    switch (status.toLowerCase()) {
      case 'signed':
        return 'signed';
      case 'partially signed':
        return 'partially-signed';
      case 'come back':
        return 'comeback';
      case 'not home':
        return 'notHome';
      case 'bas':
        return 'bas';
      default:
        return 'bas'; // Default to BAS if unknown
    }
  }

  static BitmapDescriptor getMarkerIconForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'signed':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'partially signed':
      case 'partially-signed':
        return BitmapDescriptor.defaultMarkerWithHue(140);
      case 'comeback':
      case 'come back':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case 'nothome':
      case 'not home':
      case 'nothome':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
      case 'bas':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
    }
  }
} 