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

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
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
    _mapController = controller;
    await controller.setMapStyle(MapService.mapStyle.toString());
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
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              markers: _markers,
              onMapCreated: _onMapCreated,
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
          // Map Controls
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
    if (_currentPosition == null) return;
    
    MapService.getAddressFromCoordinates(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    ).then((address) {
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
            Navigator.pop(context);
          },
        ),
      );
    });
  }
}