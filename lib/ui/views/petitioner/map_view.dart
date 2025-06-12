import 'dart:async';

import 'package:ballot_access_pro/core/locator.dart';
import 'package:ballot_access_pro/models/territory_houses.dart';
import 'package:ballot_access_pro/services/petitioner_service.dart';
import 'package:ballot_access_pro/shared/utils/debug_utils.dart';
import 'package:ballot_access_pro/shared/widgets/add_house_bottom_sheet.dart';
import 'package:ballot_access_pro/ui/widgets/map/house_status_filter.dart';
import 'package:ballot_access_pro/ui/widgets/map/house_legend.dart';
import 'package:ballot_access_pro/ui/widgets/map/map_type_toggle.dart';
import 'package:ballot_access_pro/ui/widgets/map/house_details_bottom_sheet.dart';
import 'package:ballot_access_pro/ui/widgets/map/filtered_houses_bottom_sheet.dart';
import 'package:ballot_access_pro/ui/widgets/map/update_house_status_bottom_sheet.dart';
import 'package:ballot_access_pro/ui/widgets/map/connection_status_widget.dart';
import 'package:ballot_access_pro/ui/widgets/map/sync_controls_widget.dart';
import 'package:ballot_access_pro/ui/widgets/map/work_controls_widget.dart';
import 'package:ballot_access_pro/ui/widgets/map/audio_recording_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/services/map_service.dart';
import 'package:ballot_access_pro/services/socket_service.dart';
import 'package:ballot_access_pro/models/user_location.dart';
import 'package:ballot_access_pro/services/local_storage_service.dart';
import 'package:ballot_access_pro/services/territory_service.dart';
import 'dart:convert';
import 'dart:math';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> with AutomaticKeepAliveClientMixin {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  String selectedStatus = '';
  bool _isLoading = true;
  bool _mapCreated = false;
  Set<Marker> _petitionerMarkers = {};
  final Set<Marker> _voterMarkers = {};
  MapType _currentMapType = MapType.normal;
  late SocketService _socketService;
  final Map<String, UserLocation> _userLocations = {};
  Set<Marker> _houseMarkers = {};
  Set<Polygon> _territoryPolygons = {};
  Set<Polyline> _territoryPolylines = {};
  Set<Marker> _filteredHouseMarkers = {};
  TerritoryHouses? _houses;
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isTrackingEnabled = true;
  bool _userInteractedWithMap = false;
  bool _animatingToCurrentLocation = false;
  Timer? _socketCheckTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeMap();

    // Initialize debug mode with a delay
    if (DebugUtils.isDebugMode) {
      Future.delayed(const Duration(seconds: 2), _initializeDebugMode);
    }

    // Start a timer to check connection status periodically
    Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkSocketConnection();
    });
  }

  @override
  void dispose() {
    _socketCheckTimer?.cancel();
    _positionStreamSubscription?.cancel();
    _socketService.close(); // Ensure Socket.IO connection is closed
    if (_mapController != null) {
      _mapController!.dispose();
      _mapController = null;
    }
    super.dispose();
  }

  Future<void> _initializeMap() async {
    try {
      debugPrint('Initializing map...');

      // 1. Initialize WebSocket connection
      debugPrint('Step 1: Initializing Socket.IO connection');
      await _initializeSocketConnection();
      if (!mounted) return;

      // 2. Initialize location
      debugPrint('Step 2: Initializing device location');
      await _initializeLocation();
      if (!mounted) return;

      // 3. Fetch houses (visits)
      debugPrint('Step 3: Fetching house visits');
      await _fetchHouses();
      if (!mounted) return;

      // 4. Fetch territories last (to show boundaries)
      debugPrint('Step 4: Fetching territory boundaries');
      await _fetchTerritories();

      setState(() {
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Error initializing map: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize map: ${e.toString()}')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _initializeSocketConnection() async {
    try {
      debugPrint('Initializing Socket.IO connection...');
      final userId = await locator<LocalStorageService>()
          .getStorageValue(LocalStorageKeys.userId);

      if (userId == null) {
        debugPrint('No user ID found for Socket.IO connection');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User ID not found')),
          );
        }
        return;
      }

      // Get the SocketService singleton
      _socketService = SocketService.getInstance();

      // Connect to the Socket.IO server
      await _socketService.connect(userId);

      // Listen for connection status changes
      _socketService.connectionStatus.listen((isConnected) {
        if (mounted) {
          // Send location update when reconnected
          if (isConnected && _currentPosition != null) {
            _sendTrackEvent(_currentPosition!);
          }
        }
      });

      // Listen for location updates from other users
      _socketService.addListener('location_update', (data) {
        if (mounted) {
          try {
            debugPrint('📍 Received location update: $data');
            final userLocation = UserLocation.fromJson(data);
            setState(() {
              _userLocations[userLocation.id] = userLocation;
              _updateUserMarkers();
            });
          } catch (e) {
            debugPrint('🔴 Error parsing location update: $e');
          }
        }
      });
    } catch (e, stackTrace) {
      debugPrint('Error in _initializeSocketConnection: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  Future<void> _initializeLocation() async {
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

      if (!mounted) return;

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      _updateMarkers();

      // Send location immediately upon obtaining it, even if socket appears disconnected
      _sendTrackEvent(position);

      // Start continuous location tracking with optimized settings
      _startLocationTracking();

      // Schedule recurring checks for socket connection
      _scheduleSocketChecks();
    } catch (e) {
      debugPrint('🔴 Error getting location: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showError(e.toString());
      }
    }
  }

  void _scheduleSocketChecks() {
    // Clear any existing timers
    _socketCheckTimer?.cancel();

    // Check socket connection every 10 seconds
    _socketCheckTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkSocketConnection();

      // Force a location update if we have one
      if (_currentPosition != null) {
        _sendTrackEvent(_currentPosition!);
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _updateMarkers() {
    if (_currentPosition == null) return;
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('currentLocation'),
          position:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          infoWindow: const InfoWindow(title: 'Current Location'),
        ),
      };
    });
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    debugPrint('Map created!');
    if (_mapCreated) return;

    _mapController = controller;
    setState(() {
      _mapCreated = true;
      _isLoading = false;
    });

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
    if (_currentPosition != null) {
      controller.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude), 15));
      debugPrint(
          'Animated to current position: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
    } else {
      debugPrint('No current position available for initial camera animation');
    }

    // Force an additional rebuild to ensure all UI elements are shown
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  void _animateToCurrentLocation() {
    if (_mapController == null || _currentPosition == null) return;

    _animatingToCurrentLocation = true;
    _mapController!
        .animateCamera(
      CameraUpdate.newCameraPosition(
        MapService.getCameraPosition(_currentPosition!),
      ),
    )
        .then((_) {
      _animatingToCurrentLocation = false;
      _userInteractedWithMap = false;
    });
  }

  Future<void> _fetchHouses() async {
    debugPrint('Fetching house visits using offline-first approach');
    try {
      final houses = await MapService.getHousesOfflineFirst();
      if (!mounted) return;

      if (houses != null) {
        debugPrint('Successfully fetched ${houses.docs.length} houses');
        if (mounted) {
          setState(() {
            // Store the houses data
            _houses = houses;

            _houseMarkers = houses.docs.map((house) {
              debugPrint(
                  'Creating marker for house: ${house.address} with status ${house.status}');
              return Marker(
                markerId: MarkerId('house_${house.id}'),
                position: LatLng(house.lat, house.long),
                icon: MapService.getMarkerIconForStatus(house.status),
                infoWindow: InfoWindow(
                  title: house.address,
                  snippet: '${house.registeredVoters} registered voters',
                ),
                onTap: () => _showHouseDetails(house),
              );
            }).toSet();

            // Initialize filtered markers with all house markers
            _filteredHouseMarkers = _houseMarkers;
          });
        }
      } else {
        debugPrint('No houses data received');
        if (mounted) {
          _showError('No houses found');
        }
      }
    } catch (e) {
      debugPrint('Error fetching houses: $e');
      if (mounted) {
        _showError('Failed to load houses: ${e.toString()}');
      }
    }
  }

  Future<void> _fetchTerritories() async {
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

      if (mounted) {
        setState(() {
          // Create polygons for areas with a closed shape (polygon type)
          _territoryPolygons = territories
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
          _territoryPolylines = territories
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
              'Created ${_territoryPolygons.length} polygons and ${_territoryPolylines.length} polylines');
        });
      }
    } catch (e) {
      debugPrint('Error fetching territories: $e');
    }
  }

  void _showHouseDetails(HouseVisit house) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.95,
      ),
      builder: (context) => HouseDetailsBottomSheet(
        house: house,
        onUpdateTap: _showUpdateHouseStatus,
      ),
    );
  }

  void _showUpdateHouseStatus(HouseVisit house) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UpdateHouseStatusBottomSheet(
        house: house,
        onUpdateStatus: (status, leadData) {
          // Store local reference to context
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          final currentContext = context;

          // Execute the update asynchronously after the bottom sheet is closed
          Future.microtask(() async {
            // Show loading indicator if still mounted
            if (Navigator.canPop(currentContext)) {
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Updating house status...')),
              );
            }

            // Call the offline-first API to update the status
            final success = await MapService.updateHouseStatusOfflineFirst(
              markerId: house.id,
              status: status,
              lead: leadData,
            );

            // Check if we can still show feedback
            if (mounted) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(
                    leadData != null
                        ? 'Pin Status Updated and Lead Created'
                        : 'Pin Status Updated',
                  ),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );

              // Only refresh houses if successful and mounted
              if (success) {
                await _fetchHouses();
              }
            }
          });
        },
      ),
    );
  }

  void _handleMapLongPress(LatLng position) {
    // Show immediate feedback that long press was detected
    HapticFeedback.mediumImpact();

    // Show loading indicator
    final loadingSnackBar = SnackBar(
      content: Row(
        children: [
          SizedBox(
            width: 16.w,
            height: 16.h,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(width: 8.w),
          const Text('Getting address...'),
        ],
      ),
      duration: const Duration(seconds: 1),
    );
    ScaffoldMessenger.of(context).showSnackBar(loadingSnackBar);

    // Use the correct type for territories based on the imported model
    TerritoryService.getTerritories().then((territories) {
      MapService.getAddressFromCoordinates(
              position.latitude, position.longitude)
          .then((address) {
        if (mounted) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.95,
            ),
            builder: (context) => AddHouseBottomSheet(
              currentAddress: address,
              onStatusSelected: (status) {
                // This is just for the bottom sheet internal state
              },
              selectedStatus: '',
              territories: territories,
              onAddHouse: (registeredVoters, notes, territory) {
                _addHouse(
                  position: position,
                  address: address,
                  territory: territory,
                  registeredVoters: registeredVoters,
                  notes: notes,
                );
              },
            ),
          );
        }
      });
    });
  }

  // Add the missing _addHouse method
  void _addHouse({
    required LatLng position,
    required String address,
    required String territory,
    required int registeredVoters,
    required String notes,
  }) {
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Adding house visit...')),
    );

    // Add the house visit using offline-first approach
    MapService.addHouseVisitOfflineFirst(
      lat: position.latitude,
      long: position.longitude,
      address: address,
      territory: territory,
      status: selectedStatus.isEmpty
          ? 'Signed'
          : selectedStatus, // Default to Signed
      registeredVoters: registeredVoters,
      note: notes,
    ).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('House visit added successfully')),
        );

        // Refresh houses
        _fetchHouses();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add house visit')),
        );
      }
    });
  }

  void _onStatusChanged(String status) {
    setState(() {
      selectedStatus = status;
      _filterMarkersByStatus();
    });

    // Show bottom sheet with houses filtered by the selected status
    if (status.isNotEmpty && _houses != null) {
      _showFilteredHousesBottomSheet(status);
    }
  }

  void _showFilteredHousesBottomSheet(String status) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) => FilteredHousesBottomSheet(
        status: status,
        houses: _houses!.docs,
        onViewHouse: _navigateToHouse,
      ),
    );
  }

  void _navigateToHouse(HouseVisit house) {
    if (_mapController == null) return;

    // Animate to the house's position
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(house.lat, house.long),
          zoom: 18.0,
        ),
      ),
    );

    // After a short delay, show the house details
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _showHouseDetails(house);
      }
    });
  }

  void _onMapTypeChanged(MapType mapType) {
    debugPrint('Changing map type to: $mapType');
    setState(() {
      _currentMapType = mapType;

      // If changing to satellite, use hybrid for better visibility
      if (mapType == MapType.satellite) {
        _currentMapType = MapType.hybrid;
      }
    });
  }

  void _filterMarkersByStatus() {
    if (selectedStatus.isEmpty) {
      _filteredHouseMarkers = _houseMarkers;
    } else {
      _filteredHouseMarkers = _houseMarkers.where((marker) {
        final String houseId = marker.markerId.value.replaceAll('house_', '');
        final house = _findHouseById(houseId);

        if (house == null) return false;

        // Normalize statuses for comparison
        final normalizedHouseStatus =
            _normalizeStatusForComparison(house.status);
        final normalizedSelectedStatus =
            _normalizeStatusForComparison(selectedStatus);

        return normalizedHouseStatus == normalizedSelectedStatus;
      }).toSet();

      if (_filteredHouseMarkers.isNotEmpty && _mapController != null) {
        final bounds = _calculateBounds(_filteredHouseMarkers);
        _mapController!
            .animateCamera(CameraUpdate.newLatLngBounds(bounds, 50.0));
      }
    }
  }

  // Helper method to normalize status strings for comparison
  String _normalizeStatusForComparison(String status) {
    final normalized = status.toLowerCase().trim();

    // Map UI display statuses to API statuses and vice versa
    if (normalized == 'not home') return 'nothome';
    if (normalized == 'nothome') return 'nothome';
    if (normalized == 'come back') return 'comeback';
    if (normalized == 'comeback') return 'comeback';
    if (normalized == 'partially signed') return 'partially-signed';
    if (normalized == 'partially-signed') return 'partially-signed';
    if (normalized == 'signed') return 'signed';
    if (normalized == 'bas') return 'bas';

    return normalized; // Return original if no match found
  }

  HouseVisit? _findHouseById(String id) {
    if (_houses == null) return null;

    for (final house in _houses!.docs) {
      if (house.id == id) {
        return house;
      }
    }
    return null;
  }

  LatLngBounds _calculateBounds(Set<Marker> markers) {
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

  void _startLocationTracking() {
    // Cancel any existing subscription first
    _positionStreamSubscription?.cancel();

    // Skip real GPS tracking in debug mode to prevent issues
    if (DebugUtils.isDebugMode) {
      debugPrint('📍 Using simulated location updates in debug mode');

      // Create a timer that simulates position updates every 5 seconds
      _positionStreamSubscription = Stream.periodic(
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
          if (mounted) {
            // Always update UI with new position
            setState(() {
              _currentPosition = position;
              _updateMarkers();
            });

            // Send track event for simulated position updates
            _sendTrackEvent(position);

            // Only animate map if tracking is enabled and user hasn't manually moved map
            if (_isTrackingEnabled &&
                !_userInteractedWithMap &&
                _mapController != null) {
              _animateToCurrentLocation();
            }
          }
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
    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        if (mounted) {
          // Always update UI with new position
          setState(() {
            _currentPosition = position;
            _updateMarkers();
          });

          // Send track event for EVERY position update to ensure server knows we're active
          _sendTrackEvent(position);

          // Only animate map if tracking is enabled and user hasn't manually moved map
          if (_isTrackingEnabled &&
              !_userInteractedWithMap &&
              _mapController != null) {
            _animateToCurrentLocation();
          }
        }
      },
      onError: (error) {
        debugPrint('❌ Error from location stream: $error');
        // Try to restart location tracking on error
        Future.delayed(const Duration(seconds: 3), _startLocationTracking);
      },
      onDone: () {
        debugPrint('ℹ️ Location stream completed, restarting...');
        // Restart tracking if it completes for any reason
        _startLocationTracking();
      },
    );

    debugPrint('✅ Continuous location tracking started');
  }

  void _sendTrackEvent(Position position) {
    try {
      // Always try to send track event, regardless of perceived socket status
      // The socket service will handle reconnection if needed

      // Get the profile name (you may need to adjust based on your data model)
      const String name = "Petitioner"; // Replace with actual name if available
      const String photo = ""; // Replace with actual photo URL if available
      final String id = _socketService.getUserId() ?? "unknown";

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
      _socketService.sendTrackEvent(locationData);
      debugPrint(
          '📍 Sent/queued track event: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      debugPrint('🔴 Error in _sendTrackEvent: $e');
      // If there's an error, check socket connection
      _checkSocketConnection();
    }
  }

  void _checkSocketConnection() {
    // Always try to ensure connection is established
    final userId = _socketService.getUserId();
    if (userId != null) {
      // Don't use .then() since connect() may not return a Future
      _socketService.connect(userId);

      // Use a delay instead to allow time for connection
      Future.delayed(const Duration(milliseconds: 500), () {
        // Send current location after connection attempt, whether it succeeded or not
        if (_currentPosition != null) {
          _sendTrackEvent(_currentPosition!);
          debugPrint('🔄 Connection check completed, sent current position');
        }
      });
    }
  }

  void _updateUserMarkers() {
    setState(() {
      _petitionerMarkers = _userLocations.values.map((user) {
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
    });
  }

  void _onCameraMove(CameraPosition position) {
    if (_isTrackingEnabled && !_animatingToCurrentLocation) {
      _userInteractedWithMap = true;
    }
  }

  // Special method to force initialization in debug mode
  void _initializeDebugMode() {
    if (!DebugUtils.isDebugMode) return;

    debugPrint('Forcing map initialization in debug mode');

    // Set default position if none exists
    _currentPosition ??= Position(
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

    // Mark loading as complete and ensure map is created
    setState(() {
      _isLoading = false;
      _mapCreated = true;

      // Force initialize markers if empty
      if (_markers.isEmpty) {
        _updateMarkers();
      }
    });

    // Ensure territory and house markers are initialized
    if (_houseMarkers.isEmpty) {
      _fetchHouses();
    }

    if (_territoryPolygons.isEmpty && _territoryPolylines.isEmpty) {
      _fetchTerritories();
    }

    // Force UI refresh on a delay with multiple attempts to ensure controls appear
    for (int i = 1; i <= 3; i++) {
      Future.delayed(Duration(seconds: i), () {
        if (mounted) {
          setState(() {});
          debugPrint('Debug mode UI refresh attempt $i completed');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Special handling for debug mode
    if (DebugUtils.isDebugMode && !_mapCreated) {
      // Force initialization complete after a timeout in debug mode
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_mapCreated) {
          setState(() {
            _mapCreated = true;
            _isLoading = false;
            _currentPosition ??= Position(
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

            // Force initialize markers in build if empty
            if (_markers.isEmpty) {
              _updateMarkers();
            }
          });
        }
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          else
            GoogleMap(
              initialCameraPosition: _currentPosition != null
                  ? MapService.getCameraPosition(_currentPosition!)
                  : const CameraPosition(
                      target: LatLng(
                          40.7128, -74.0060), // Default to NYC if no position
                      zoom: 12,
                    ),
              mapType: _currentMapType,
              myLocationEnabled: true,
              myLocationButtonEnabled:
                  false, // Hide the default location button
              zoomControlsEnabled: false, // Hide the zoom +/- buttons
              mapToolbarEnabled:
                  false, // Hide the navigation buttons that appear after marker tap
              compassEnabled: false, // Hide the compass button
              markers: {
                ..._markers,
                ..._petitionerMarkers,
                ..._voterMarkers,
                ..._filteredHouseMarkers,
              },
              polygons: _territoryPolygons,
              polylines: _territoryPolylines,
              onMapCreated: _onMapCreated,
              onCameraMove: _onCameraMove,
              key: ValueKey('google_map_${_currentMapType.toString()}'),
              onLongPress: _handleMapLongPress,
              trafficEnabled: false,
              buildingsEnabled: true,
              indoorViewEnabled: false,
              liteModeEnabled: false,
              padding: EdgeInsets.zero,
            ),
          // Error indicator for debugging - will show if map fails to load
          if (!_isLoading && !_mapCreated && _currentPosition != null)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const Text('Map failed to load',
                      style: TextStyle(color: Colors.red)),
                  Text(
                      'Position: ${_currentPosition?.latitude}, ${_currentPosition?.longitude}',
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          Positioned(
            top: 50.h,
            left: 16.w,
            right: 16.w,
            child: HouseStatusFilter(
              selectedStatus: selectedStatus,
              onStatusChanged: _onStatusChanged,
            ),
          ),
          // House Legend - display the legend for house statuses
          Positioned(
            top: 120.h, // Below the House Status Filter
            left: 16.w,
            child: const HouseLegend(),
          ),
          // Map Type Toggle - switch between map types
          Positioned(
            top: 120.h, // Below the House Status Filter
            right: 16.w,
            child: MapTypeToggle(
              currentMapType: _currentMapType,
              onMapTypeChanged: _onMapTypeChanged,
            ),
          ),
          // Connection Status Widget - shows online/offline status
          Positioned(
            top: 240.h, // Shifted up from 260.h
            left: 16.w,
            child: const ConnectionStatusWidget(),
          ),
          // Sync Controls Widget - manual sync and refresh buttons
          Positioned(
            top: 160.h, // Shifted up from 190.h
            right: 16.w,
            child: SyncControlsWidget(
              onRefreshRequested: _fetchHouses,
            ),
          ),
          // Work Controls Widget centered at bottom
          Positioned(
            bottom: 16.h,
            left: 0,
            right: 0,
            child: const Center(
              child: WorkControlsWidget(),
            ),
          ),
          // Audio Recording Button - to the left
          Positioned(
            bottom: 16.h,
            left: 16.w,
            child: const AudioRecordingButton(),
          ),
          // Location Button - at the bottom right
          Positioned(
            bottom: 16.h,
            right: 16.w,
            child: FloatingActionButton(
              heroTag: 'locate',
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () {
                _animateToCurrentLocation();
                setState(() {
                  _isTrackingEnabled = true;
                  _userInteractedWithMap = false;
                });
              },
              child: const Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
