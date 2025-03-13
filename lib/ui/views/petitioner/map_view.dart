import 'package:ballot_access_pro/shared/widgets/add_house_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  String selectedStatus = '';
  GoogleMapController? _mapController;
  Location _location = Location();
  LatLng? _currentPosition;
  String _currentAddress = 'Fetching location...';
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
      _setupLocationListener();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      _updateAddress();
      _animateToCurrentLocation();
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  void _setupLocationListener() {
    _location.onLocationChanged.listen((LocationData locationData) {
      if (mounted && locationData.latitude != null && locationData.longitude != null) {
        setState(() {
          _currentPosition = LatLng(locationData.latitude!, locationData.longitude!);
          _updateMarker();
        });
      }
    });
  }

  Future<void> _updateAddress() async {
    if (_currentPosition == null) return;
    // TODO: Implement reverse geocoding to get address from coordinates
    setState(() {
      _currentAddress = '${_currentPosition!.latitude}, ${_currentPosition!.longitude}';
    });
  }

  void _updateMarker() {
    if (_currentPosition == null) return;
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: _currentPosition!,
          infoWindow: const InfoWindow(title: 'Current Location'),
        ),
      };
    });
  }

  void _animateToCurrentLocation() {
    if (_mapController != null && _currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentPosition!,
            zoom: 15,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: 15,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  markers: _markers,
                ),
          // Status Filter Bar
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
                    _buildStatusChip('All', Colors.grey),
                    SizedBox(width: 8.w),
                    _buildStatusChip('Signed', Colors.green),
                    SizedBox(width: 8.w),
                    _buildStatusChip('Come Back', Colors.orange),
                    SizedBox(width: 8.w),
                    _buildStatusChip('Not Home', Colors.blue),
                    SizedBox(width: 8.w),
                    _buildStatusChip('BAS', Colors.red),
                  ],
                ),
              ),
            ),
          ),
          // Buttons
          Positioned(
            bottom: 16.h,
            right: 16.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'locate',
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: _animateToCurrentLocation,
                  child: const Icon(Icons.my_location, color: AppColors.primary),
                ),
                SizedBox(height: 8.h),
                FloatingActionButton.extended(
                  heroTag: 'add',
                  backgroundColor: AppColors.primary,
                  onPressed: () => _showAddHouseBottomSheet(context),
                  icon: const Icon(Icons.add_location_alt, color: Colors.white),
                  label: Text(
                    'Add Pin',
                    style: AppTextStyle.semibold16.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    final isSelected = selectedStatus == label;
    return FilterChip(
      label: Text(
        label,
        style: AppTextStyle.regular12.copyWith(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          selectedStatus = selected ? label : '';
        });
      },
      backgroundColor: Colors.white,
      selectedColor: color,
      checkmarkColor: Colors.white,
      side: BorderSide(color: color),
    );
  }

  void _showAddHouseBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddHouseBottomSheet(
        currentAddress: _currentAddress,
        selectedStatus: selectedStatus,
        onStatusSelected: (status) {
          setState(() => selectedStatus = status);
        },
        onAddHouse: () {
          // TODO: Implement add house logic
          Navigator.pop(context);
        },
      ),
    );
  }
}