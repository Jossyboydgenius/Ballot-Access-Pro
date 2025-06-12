import 'dart:async';

import 'package:ballot_access_pro/services/map_service.dart';
import 'package:ballot_access_pro/shared/utils/debug_utils.dart';
import 'package:ballot_access_pro/ui/widgets/map/controllers/bottom_sheet_controller.dart';
import 'package:ballot_access_pro/ui/widgets/map/controllers/house_marker_controller.dart';
import 'package:ballot_access_pro/ui/widgets/map/controllers/location_controller.dart';
import 'package:ballot_access_pro/ui/widgets/map/controllers/map_controller.dart';
import 'package:ballot_access_pro/ui/widgets/map/controllers/socket_controller.dart';
import 'package:ballot_access_pro/ui/widgets/map/controllers/territory_controller.dart';
import 'package:ballot_access_pro/ui/widgets/map/house_status_filter.dart';
import 'package:ballot_access_pro/ui/widgets/map/house_legend.dart';
import 'package:ballot_access_pro/ui/widgets/map/map_type_toggle.dart';
import 'package:ballot_access_pro/ui/widgets/map/connection_status_widget.dart';
import 'package:ballot_access_pro/ui/widgets/map/sync_controls_widget.dart';
import 'package:ballot_access_pro/ui/widgets/map/work_controls_widget.dart';
import 'package:ballot_access_pro/ui/widgets/map/audio_recording_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';

class MapViewWidget extends StatefulWidget {
  const MapViewWidget({super.key});

  @override
  State<MapViewWidget> createState() => _MapViewWidgetState();
}

class _MapViewWidgetState extends State<MapViewWidget> {
  // Default camera position (NYC)
  static const CameraPosition _defaultCameraPosition = CameraPosition(
    target: LatLng(40.7128, -74.0060),
    zoom: 12,
  );

  // Controllers
  late MapController _mapController;
  late LocationController _locationController;
  late SocketController _socketController;
  late HouseMarkerController _houseMarkerController;
  late TerritoryController _territoryController;
  late BottomSheetController _bottomSheetController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _mapController = MapController(onStateChanged: _handleStateChange);

    _locationController = LocationController(
      onStateChanged: _handleStateChange,
      onPositionUpdated: _handlePositionUpdate,
    );

    _socketController = SocketController(
      onStateChanged: _handleStateChange,
    );

    _houseMarkerController = HouseMarkerController(
      onStateChanged: _handleStateChange,
      onHouseTapped: _handleHouseTapped,
    );

    _territoryController = TerritoryController(
      onStateChanged: _handleStateChange,
    );

    _bottomSheetController = BottomSheetController(
      refreshHouses: _fetchHouses,
    );

    _initializeMapComponents();

    // Initialize debug mode with a delay if needed
    if (DebugUtils.isDebugMode) {
      Future.delayed(const Duration(seconds: 2), _initializeDebugMode);
    }
  }

  void _handleStateChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handlePositionUpdate(position) {
    // Send position to socket controller
    _socketController.sendTrackEvent(position);

    // Auto-animate to current location if tracking is enabled
    if (_locationController.isTrackingEnabled &&
        !_mapController.userInteractedWithMap &&
        _mapController.mapController != null &&
        !_mapController.animatingToCurrentLocation) {
      _mapController.animateToCurrentLocation(position);
    }
  }

  void _handleHouseTapped(house) {
    _bottomSheetController.showHouseDetails(context, house);
  }

  Future<void> _initializeMapComponents() async {
    try {
      // 1. Initialize WebSocket connection
      debugPrint('Step 1: Initializing Socket.IO connection');
      await _socketController.initializeSocketConnection();
      if (!mounted) return;

      // 2. Initialize location
      debugPrint('Step 2: Initializing device location');
      await _locationController.initializeLocation();
      if (!mounted) return;

      // Schedule socket checks with the current position
      _socketController
          .scheduleSocketChecks(_locationController.currentPosition);

      // 3. Fetch houses (visits)
      debugPrint('Step 3: Fetching house visits');
      await _fetchHouses();
      if (!mounted) return;

      // 4. Fetch territories last (to show boundaries)
      debugPrint('Step 4: Fetching territory boundaries');
      await _territoryController.fetchTerritories();

      if (mounted) {
        setState(() {
          _mapController.isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Error initializing map: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize map: ${e.toString()}')),
        );
        setState(() {
          _mapController.isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchHouses() async {
    return _houseMarkerController.fetchHouses();
  }

  void _initializeDebugMode() {
    if (!DebugUtils.isDebugMode) return;

    debugPrint('Forcing map initialization in debug mode');

    // Initialize all controllers for debug mode
    _locationController.initializeDebugMode();

    setState(() {
      _mapController.isLoading = false;
      _mapController.isMapCreated = true;
    });
  }

  void _onStatusChanged(String status) {
    // Update house marker controller
    _houseMarkerController.onStatusChanged(
        status, _mapController.mapController);

    // Update bottom sheet controller
    _bottomSheetController.selectedStatus = status;

    // Show bottom sheet with houses filtered by the selected status
    if (status.isNotEmpty && _houseMarkerController.houses != null) {
      _bottomSheetController.showFilteredHousesBottomSheet(
        context,
        status,
        _houseMarkerController.houses!.docs,
        (house) => _houseMarkerController.navigateToHouse(
            house, _mapController.mapController),
      );
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    _mapController.dispose();
    _locationController.dispose();
    _socketController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Special handling for debug mode
    if (DebugUtils.isDebugMode && !_mapController.isMapCreated) {
      // Force initialization complete after a timeout in debug mode
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_mapController.isMapCreated) {
          _initializeDebugMode();
        }
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          if (_mapController.isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          else
            GoogleMap(
              initialCameraPosition: _locationController.currentPosition != null
                  ? MapService.getCameraPosition(
                      _locationController.currentPosition!)
                  : _defaultCameraPosition,
              mapType: _mapController.currentMapType,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              markers: {
                ..._locationController.markers,
                ..._socketController.petitionerMarkers,
                ..._houseMarkerController.filteredHouseMarkers,
              },
              polygons: _territoryController.territoryPolygons,
              polylines: _territoryController.territoryPolylines,
              onMapCreated: (controller) => _mapController.onMapCreated(
                  controller, context, _locationController.currentPosition),
              onCameraMove: (position) => _mapController.onCameraMove(
                  position, _locationController.isTrackingEnabled),
              key: ValueKey(
                  'google_map_${_mapController.currentMapType.toString()}'),
              onLongPress: (position) =>
                  _bottomSheetController.handleMapLongPress(context, position),
              trafficEnabled: false,
              buildingsEnabled: true,
              indoorViewEnabled: false,
              liteModeEnabled: false,
              padding: EdgeInsets.zero,
            ),
          // Error indicator for debugging - will show if map fails to load
          if (!_mapController.isLoading &&
              !_mapController.isMapCreated &&
              _locationController.currentPosition != null)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const Text('Map failed to load',
                      style: TextStyle(color: Colors.red)),
                  Text(
                      'Position: ${_locationController.currentPosition?.latitude}, ${_locationController.currentPosition?.longitude}',
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          Positioned(
            top: 50.h,
            left: 16.w,
            right: 16.w,
            child: HouseStatusFilter(
              selectedStatus: _houseMarkerController.selectedStatus,
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
              currentMapType: _mapController.currentMapType,
              onMapTypeChanged: _mapController.onMapTypeChanged,
            ),
          ),
          // Connection Status Widget - shows online/offline status
          Positioned(
            top: 240.h,
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
          // Audio Recording Button - at the left edge
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
                _mapController.animateToCurrentLocation(
                    _locationController.currentPosition);
                setState(() {
                  _locationController.isTrackingEnabled = true;
                  _mapController.userInteractedWithMap = false;
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
