import 'package:ballot_access_pro/core/locator.dart';
import 'package:ballot_access_pro/models/territory_houses.dart';
import 'package:ballot_access_pro/shared/widgets/add_house_bottom_sheet.dart';
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
      
      // Initialize socket first
      await _initializeSocket();
      if (!mounted) return;

      // Initialize location
      await _initializeLocation();
      if (!mounted) return;

      // Get current territory
      _currentTerritory = await TerritoryService.getCurrentTerritory();
      if (!mounted) return;

      // Fetch territories
      await _fetchTerritories();
      if (!mounted) return;

      // Fetch houses
      await _fetchHouses();
      
      // Fetch petitioners and voters last
      if (mounted) {
        await _fetchPetitionersAndVoters();
      }
    } catch (e, stackTrace) {
      debugPrint('Error initializing map: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize map: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
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
      final territories = await TerritoryService.getTerritories();
      if (mounted) {
        setState(() {
          _territoryPolygons = TerritoryService.createTerritoryPolygons(territories);
          _territoryPolylines = TerritoryService.createTerritoryPolylines(territories);
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
      builder: (context) => Container(
        width: double.infinity, // Make container take full available width
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 5.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.5.r),
                ),
              ),
            ),
            Text(
              house.address,
              style: AppTextStyle.semibold16,
            ),
            SizedBox(height: 8.h),
            Text(
              'Status: ${house.status.toUpperCase()}',
              style: AppTextStyle.regular14.copyWith(
                color: house.statusColor.startsWith('#')
                  ? Color(int.parse('0xFF${house.statusColor.substring(1)}'))
                  : Colors.black,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Registered Voters: ${house.registeredVoters}',
              style: AppTextStyle.regular14,
            ),
            if (house.notes.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                'Notes: ${house.notes}',
                style: AppTextStyle.regular14,
              ),
            ],
            SizedBox(height: 8.h),
            Text(
              'Petitioner: ${house.petitioner.firstName} ${house.petitioner.lastName}',
              style: AppTextStyle.regular14,
            ),
            SizedBox(height: 8.h),
            Text(
              'Last Updated: ${DateFormat('MMM dd, yyyy HH:mm').format(house.updatedAt)}',
              style: AppTextStyle.regular12.copyWith(color: Colors.grey),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
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
                      target: LatLng(0, 0),
                      zoom: 2,
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
                ..._houseMarkers, // Make sure house markers are included
              },
              onMapCreated: _onMapCreated,
              key: const ValueKey('google_map'),
              onLongPress: _handleMapLongPress,
              polygons: _territoryPolygons,
              polylines: _territoryPolylines,
            ),
          Positioned(
            top: 50.h,
            left: 16.w,
            right: 16.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStatusChip('Signed', AppColors.green100),
                    SizedBox(width: 8.w),
                    _buildStatusChip('Partially Signed', AppColors.green.withOpacity(0.6)),
                    SizedBox(width: 8.w),
                    _buildStatusChip('Come Back', Colors.blue),
                    SizedBox(width: 8.w),
                    _buildStatusChip('Not Home', Colors.yellow),
                    SizedBox(width: 8.w),
                    _buildStatusChip('BAS', Colors.red),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 120.h,
            right: 16.w,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      debugPrint('Switching to normal map');
                      setState(() {
                        _currentMapType = MapType.normal;
                      });
                    },
                    child: Text(
                      'Map',
                      style: AppTextStyle.regular14.copyWith(
                        color: _currentMapType == MapType.normal 
                            ? AppColors.primary 
                            : Colors.grey,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      debugPrint('Switching to satellite map');
                      setState(() {
                        _currentMapType = MapType.satellite;
                      });
                    },
                    child: Text(
                      'Satellite',
                      style: AppTextStyle.regular14.copyWith(
                        color: _currentMapType == MapType.satellite 
                            ? AppColors.primary 
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
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

  Widget _buildStatusChip(String label, Color color) {
    final isSelected = selectedStatus == label;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12.r,
            height: 12.r,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: AppTextStyle.regular12.copyWith(
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          selectedStatus = selected ? label : '';
        });
      },
      backgroundColor: Colors.white,
      selectedColor: color,
      showCheckmark: false,
      side: BorderSide(color: color),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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
}