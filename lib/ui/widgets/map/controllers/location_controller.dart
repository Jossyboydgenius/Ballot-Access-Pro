import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ballot_access_pro/services/map_service.dart';
import 'package:ballot_access_pro/shared/utils/debug_utils.dart';

class LocationController {
  Position? currentPosition;
  StreamSubscription<Position>? positionStreamSubscription;
  bool isTrackingEnabled = true;
  Set<Marker> markers = {};

  // Callback to be called when location state changes
  final Function() onStateChanged;
  // Callback for when position updates
  final Function(Position) onPositionUpdated;

  LocationController({
    required this.onStateChanged,
    required this.onPositionUpdated,
  });

  void dispose() {
    positionStreamSubscription?.cancel();
  }

  Future<void> initializeLocation() async {
    try {
      Position position;

      // In debug mode, use fixed coordinates to prevent issues
      if (DebugUtils.isDebugMode) {
        // Use a valid fixed position for debugging (Ghana coordinates)
        position = Position(
          longitude: -0.1870,
          latitude: 5.6037,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
        debugPrint(
            'Using fixed position for debug mode: ${position.latitude}, ${position.longitude}');
      } else {
        position = await MapService.getCurrentLocation();
      }

      currentPosition = position;
      onStateChanged();

      updateMarkers();

      // Notify about position update
      onPositionUpdated(position);

      // Start continuous location tracking with optimized settings
      startLocationTracking();
    } catch (e) {
      debugPrint('🔴 Error getting location: $e');
    }
  }

  void updateMarkers() {
    if (currentPosition == null) return;

    markers = {
      Marker(
        markerId: const MarkerId('currentLocation'),
        position: LatLng(currentPosition!.latitude, currentPosition!.longitude),
        infoWindow: const InfoWindow(title: 'Current Location'),
      ),
    };

    onStateChanged();
  }

  void startLocationTracking() {
    // Cancel any existing subscription first
    positionStreamSubscription?.cancel();

    // Skip real GPS tracking in debug mode to prevent issues
    if (DebugUtils.isDebugMode) {
      debugPrint('📍 Using simulated location updates in debug mode');

      // Create a timer that simulates position updates every 5 seconds
      positionStreamSubscription = Stream.periodic(
        const Duration(seconds: 5),
        (count) {
          // Simulate small position changes
          final randomLat = (0.0001 * (count % 10)) * (count % 2 == 0 ? 1 : -1);
          final randomLng =
              (0.0001 * ((count + 3) % 10)) * (count % 2 == 0 ? -1 : 1);

          return Position(
            longitude: -0.1870 + randomLng,
            latitude: 5.6037 + randomLat,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
        },
      ).listen(
        (Position position) {
          // Always update UI with new position
          currentPosition = position;
          updateMarkers();

          // Notify about position update
          onPositionUpdated(position);
        },
        onError: (error) {
          debugPrint('❌ Error from simulated location stream: $error');
        },
      );

      debugPrint('✅ Simulated location tracking started for debug mode');
      return;
    }

    // For release mode, use actual GPS tracking
    // Configure more aggressive location settings for more frequent updates
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Update when moved at least 5 meters
      timeLimit: Duration(seconds: 3), // Check every 3 seconds
    );

    debugPrint(
        '📍 Starting continuous location tracking with aggressive settings');

    // Subscribe to position stream
    positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        // Always update UI with new position
        currentPosition = position;
        updateMarkers();

        // Notify about position update
        onPositionUpdated(position);
      },
      onError: (error) {
        debugPrint('❌ Error from location stream: $error');
        // Try to restart location tracking on error
        Future.delayed(const Duration(seconds: 3), startLocationTracking);
      },
      onDone: () {
        debugPrint('ℹ️ Location stream completed, restarting...');
        // Restart tracking if it completes for any reason
        startLocationTracking();
      },
    );

    debugPrint('✅ Continuous location tracking started');
  }

  // For debug mode initialization
  void initializeDebugMode() {
    if (!DebugUtils.isDebugMode) return;

    debugPrint('Forcing location initialization in debug mode');

    // Set default position if none exists
    currentPosition ??= Position(
      longitude: -0.1870,
      latitude: 5.6037,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );

    // Force initialize markers if empty
    if (markers.isEmpty) {
      updateMarkers();
    }

    onStateChanged();
  }
}
