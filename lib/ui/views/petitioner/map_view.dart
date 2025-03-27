import 'package:ballot_access_pro/shared/widgets/add_house_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:ballot_access_pro/services/map_service.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _fetchPetitionersAndVoters();
  }

  @override
  void dispose() {
    if (_mapController != null) {
      _mapController!.dispose();
      _mapController = null;
    }
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      final position = await MapService.getCurrentLocation();
      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });
      _updateMarkers();
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
    if (_mapCreated) return;
    _mapController = controller;
    _mapCreated = true;
    
    try {
      // Convert the map style list to a JSON string
      final String style = MapService.mapStyle is List 
          ? '[${MapService.mapStyle.map((e) => e.toString()).join(',')}]'
          : MapService.mapStyle.toString();
      
      await controller.setMapStyle(style);
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
              mapType: MapType.satellite,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              markers: {..._markers, ..._petitionerMarkers, ..._voterMarkers},
              onMapCreated: _onMapCreated,
              key: const ValueKey('google_map'),
              onLongPress: _handleMapLongPress,
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
        onAddHouse: () {
          setState(() {
            _markers.add(
              Marker(
                markerId: MarkerId(DateTime.now().toString()),
                position: position,
                infoWindow: InfoWindow(title: address),
              ),
            );
          });
          Navigator.pop(context);
        },
      ),
    );
  }
}