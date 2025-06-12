import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ballot_access_pro/core/locator.dart';
import 'package:ballot_access_pro/models/user_location.dart';
import 'package:ballot_access_pro/services/socket_service.dart';
import 'package:ballot_access_pro/services/local_storage_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SocketController {
  late SocketService socketService;
  final Map<String, UserLocation> userLocations = {};
  Set<Marker> petitionerMarkers = {};
  Timer? socketCheckTimer;

  // Callback to be called when socket state changes
  final Function() onStateChanged;

  SocketController({required this.onStateChanged});

  void dispose() {
    socketCheckTimer?.cancel();
    socketService.close();
  }

  Future<void> initializeSocketConnection() async {
    try {
      debugPrint('Initializing Socket.IO connection...');
      final userId = await locator<LocalStorageService>()
          .getStorageValue(LocalStorageKeys.userId);

      if (userId == null) {
        debugPrint('No user ID found for Socket.IO connection');
        return;
      }

      // Get the SocketService singleton
      socketService = SocketService.getInstance();

      // Connect to the Socket.IO server
      await socketService.connect(userId);

      // Listen for connection status changes
      socketService.connectionStatus.listen((isConnected) {
        // This will be handled by sending location on reconnect
      });

      // Listen for location updates from other users
      socketService.addListener('location_update', (data) {
        try {
          debugPrint('📍 Received location update: $data');
          final userLocation = UserLocation.fromJson(data);
          userLocations[userLocation.id] = userLocation;
          updateUserMarkers();
        } catch (e) {
          debugPrint('🔴 Error parsing location update: $e');
        }
      });
    } catch (e, stackTrace) {
      debugPrint('Error in initializeSocketConnection: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  void scheduleSocketChecks(Position? currentPosition) {
    // Clear any existing timers
    socketCheckTimer?.cancel();

    // Check socket connection every 10 seconds
    socketCheckTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      checkSocketConnection();

      // Force a location update if we have one
      if (currentPosition != null) {
        sendTrackEvent(currentPosition);
      }
    });
  }

  void checkSocketConnection() {
    // Always try to ensure connection is established
    final userId = socketService.getUserId();
    if (userId != null) {
      // Don't use .then() since connect() may not return a Future
      socketService.connect(userId);

      // Use a delay instead to allow time for connection
      Future.delayed(const Duration(milliseconds: 500), () {
        // Connection check completed
        debugPrint('🔄 Connection check completed');
      });
    }
  }

  void sendTrackEvent(Position position) {
    try {
      // Always try to send track event, regardless of perceived socket status
      // The socket service will handle reconnection if needed

      // Get the profile name (you may need to adjust based on your data model)
      const String name = "Petitioner"; // Replace with actual name if available
      const String photo = ""; // Replace with actual photo URL if available
      final String id = socketService.getUserId() ?? "unknown";

      // Prepare location data with unique timestamp to prevent duplicates
      final locationData = {
        "longitude": position.longitude.toString(),
        "latitude": position.latitude.toString(),
        "name": name,
        "photo": photo,
        "id": id,
        "accuracy": position.accuracy.toString(),
        "altitude": position.altitude.toString(),
        "speed": position.speed.toString(),
        "heading": position.heading.toString(),
        "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
      };

      // Always try to send, the socket service will handle connection issues
      socketService.sendTrackEvent(locationData);
      debugPrint(
          '📍 Sent/queued track event: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      debugPrint('🔴 Error in sendTrackEvent: $e');
      // If there's an error, check socket connection
      checkSocketConnection();
    }
  }

  void updateUserMarkers() {
    petitionerMarkers = userLocations.values.map((user) {
      return Marker(
        markerId: MarkerId('user_${user.id}'),
        position: LatLng(user.latitude, user.longitude),
        infoWindow: InfoWindow(
          title: user.name,
          snippet: 'Active Petitioner',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
    }).toSet();

    onStateChanged();
  }
}
