import 'package:ballot_access_pro/core/locator.dart';
import 'package:ballot_access_pro/models/territory_houses.dart';
import 'package:ballot_access_pro/shared/widgets/add_house_bottom_sheet.dart';
import 'package:ballot_access_pro/ui/widgets/map/house_status_filter.dart';
import 'package:ballot_access_pro/ui/widgets/map/house_legend.dart';
import 'package:ballot_access_pro/ui/widgets/map/map_type_toggle.dart';
import 'package:ballot_access_pro/ui/widgets/map/house_details_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:ballot_access_pro/services/map_service.dart';
import 'package:ballot_access_pro/services/socket_service.dart';
import 'package:ballot_access_pro/models/user_location.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:intl/intl.dart';
import 'package:ballot_access_pro/services/local_storage_service.dart';
import 'package:ballot_access_pro/services/territory_service.dart';
import 'dart:convert';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  String selectedStatus = '';
  bool _isLoading = true;
  bool _mapCreated = false;
  Set<Marker> _petitionerMarkers = {};
  Set<Marker> _voterMarkers = {};
  MapType _currentMapType = MapType.normal;
  late SocketService _socketService;
  Map<String, UserLocation> _userLocations = {};
  bool _socketConnected = false;
  Set<Marker> _houseMarkers = {};
  String? _currentTerritory;
  Set<Polygon> _territoryPolygons = {};
  Set<Polyline> _territoryPolylines = {};

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _socketService.dispose();
    if (_mapController != null) {
      _mapController!.dispose();
      _mapController = null;
    }
    super.dispose();
  }

  Future<void> _initializeMap() async {
    try {
      debugPrint('Initializing map...');
      
      // 1. Connect to socket first for location tracking
      debugPrint('Step 1: Initializing socket connection');
      await _initializeSocket();
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

  Future<void> _initializeSocket() async {
    try {
      debugPrint('Initializing socket connection...');
      final token = await locator<LocalStorageService>().getStorageValue(LocalStorageKeys.accessToken);
      if (token == null) {
        debugPrint('No auth token found for socket connection');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authentication required')),
          );
        }
        return;
      }

      _socketService = SocketService.getInstance(token);
      _setupSocketListeners();
    } catch (e, stackTrace) {
      debugPrint('Error in _initializeSocket: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  void _setupSocketListeners() {
    if (!_socketService.isInitialized) {
      debugPrint('Socket not properly initialized');
      return;
    }

    _socketService.socket.onConnect((_) {
      if (!mounted) return;
      debugPrint('Socket connected successfully');
      setState(() => _socketConnected = true);
      if (_currentPosition != null) {
        _emitLocation();
      }
    });

    _socketService.socket.onDisconnect((_) {
      debugPrint('Socket disconnected');
      setState(() => _socketConnected = false);
    });

    _socketService.socket.onConnectError((data) {
      debugPrint('Socket connection error: $data');
    });

    _socketService.socket.onError((data) {
      debugPrint('Socket error: $data');
    });

    _socketService.socket.on('location_update', (data) {
      if (data != null) {
        try {
          final userLocation = UserLocation.fromJson(data);
        setState(() {
            _userLocations[userLocation.id] = userLocation;
            _updateUserMarkers();
        });
        } catch (e) {
          debugPrint('Error parsing location update: $e');
        }
      }
    });
  }

  void _emitLocation() {
    if (_currentPosition != null && _socketConnected) {
      _socketService.emit('update_location', {
        'latitude': _currentPosition!.latitude.toString(),
        'longitude': _currentPosition!.longitude.toString(),
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

  @override
  Future<void> _initializeLocation() async {
    try {
      final position = await MapService.getCurrentLocation();
      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });
      _updateMarkers();
      _emitLocation(); // Emit location when we get it
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
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
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          infoWindow: const InfoWindow(title: 'Current Location'),
        ),
      };
    });
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    debugPrint('Map created!');
    if (_mapCreated) return;
    
    _mapController = controller;
    _mapCreated = true;
    
    try {
      // Convert the map style list to a JSON string
      final String style = jsonEncode(MapService.mapStyle);
      await controller.setMapStyle(style);
      debugPrint('Map style set successfully');
    } catch (e) {
      debugPrint('Error setting map style: $e');
      // Continue even if map style fails
    }
    
    if (_currentPosition != null) {
      _animateToCurrentLocation();
    }
  }

  void _animateToCurrentLocation() {
    if (_mapController == null || _currentPosition == null) return;
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
        MapService.getCameraPosition(_currentPosition!),
      ),
    );
  }

  Future<void> _fetchPetitionersAndVoters() async {
    // TODO: Implement API call to fetch petitioners and voters locations
    // This should update _petitionerMarkers and _voterMarkers
  }

  Future<void> _fetchHouses() async {
    debugPrint('Fetching house visits');
    try {
      final houses = await MapService.getHousesForTerritory();
      if (!mounted) return;
      
      if (houses != null) {
        debugPrint('Successfully fetched ${houses.docs.length} houses');
        if (mounted) {
          setState(() {
            _houseMarkers = houses.docs.map((house) {
              debugPrint('Creating marker for house: ${house.address} with status ${house.status}');
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
      
      if (mounted) {
        setState(() {
          // Create polygons for areas with a closed shape (polygon type)
          _territoryPolygons = territories
              .where((territory) => 
                territory.boundary?.type == 'polygon' && 
                territory.boundary!.paths.isNotEmpty)
              .map((territory) {
                debugPrint('Creating polygon for territory: ${territory.name}');
                return Polygon(
                  polygonId: PolygonId(territory.id),
                  points: territory.boundary!.paths
                      .map((point) => LatLng(point.lat, point.lng))
                      .toList(),
                  strokeWidth: 2,
                  strokeColor: Colors.red,
                  fillColor: Colors.red.withOpacity(0.3),
                );
              }).toSet();
              
          // Create polylines for paths (polyline type)
          _territoryPolylines = territories
              .where((territory) => 
                territory.boundary?.type == 'polyline' && 
                territory.boundary!.paths.isNotEmpty)
              .map((territory) {
                debugPrint('Creating polyline for territory: ${territory.name}');
                return Polyline(
                  polylineId: PolylineId(territory.id),
                  points: territory.boundary!.paths
                      .map((point) => LatLng(point.lat, point.lng))
                      .toList(),
                  width: 3,
                  color: Colors.red,
                );
              }).toSet();
              
          debugPrint('Created ${_territoryPolygons.length} polygons and ${_territoryPolylines.length} polylines');
        });
      }
    } catch (e) {
      debugPrint('Error fetching territories: $e');
    }
  }

  BitmapDescriptor _getMarkerIconForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'signed':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'partially signed':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
      case 'come back':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case 'not home':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
      case 'bas':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
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
        maxWidth: MediaQuery.of(context).size.width * 0.95, // Set width to 95% of screen width
      ),
      builder: (context) => HouseDetailsBottomSheet(house: house),
    );
  }

  void _handleMapLongPress(LatLng position) async {
    final address = await MapService.getAddressFromCoordinates(
      position.latitude,
      position.longitude,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddHouseBottomSheet(
        currentAddress: address,
        selectedStatus: selectedStatus,
        onStatusSelected: (status) {
          setState(() => selectedStatus = status);
        },
        onAddHouse: (voters, notes) async {
          // Show loading indicator
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Adding house visit...')),
          );
          
          // Add the house visit
          final success = await MapService.addHouseVisit(
            lat: position.latitude,
            long: position.longitude,
            address: address,
            territory: _currentTerritory ?? '67d35ef14c19c778bbe7b597',
            status: selectedStatus.isEmpty ? 'BAS' : selectedStatus,
            registeredVoters: voters,
            note: notes,
          );
          
          // Handle the result
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('House visit added successfully')),
            );
            
            // Refresh houses
            await _fetchHouses();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to add house visit')),
            );
          }
          
          Navigator.pop(context);
        },
        ),
      );
    }

  void _onStatusChanged(String status) {
    setState(() {
      selectedStatus = status;
    });
  }
  
  void _onMapTypeChanged(MapType mapType) {
    setState(() {
      _currentMapType = mapType;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      target: LatLng(40.7128, -74.0060), // New York as default
                      zoom: 12,
                    ),
              mapType: _currentMapType,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              markers: {
                ..._markers,
                ..._petitionerMarkers,
                ..._voterMarkers,
                ..._houseMarkers,
              },
              polygons: _territoryPolygons,
              polylines: _territoryPolylines,
              onMapCreated: _onMapCreated,
              key: const ValueKey('google_map'),
              onLongPress: _handleMapLongPress,
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
          Positioned(
            top: 120.h,
            left: 16.w,
            child: HouseLegend(),
          ),
          Positioned(
            top: 120.h,
            right: 16.w,
            child: MapTypeToggle(
              currentMapType: _currentMapType,
              onMapTypeChanged: _onMapTypeChanged,
            ),
          ),
          Positioned(
            bottom: 16.h,
            right: 16.w,
            child: FloatingActionButton(
                  heroTag: 'locate',
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: _animateToCurrentLocation,
                  child: const Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}