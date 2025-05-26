import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../shared/styles/app_text_style.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../models/petitioner_model.dart';
import '../../../services/petitioner_service.dart';
import '../../../core/locator.dart';
// You'll need to import your map package (Google Maps, MapBox, etc.)

class TerritoryMapView extends StatefulWidget {
  const TerritoryMapView({super.key});

  @override
  State<TerritoryMapView> createState() => _TerritoryMapViewState();
}

class _TerritoryMapViewState extends State<TerritoryMapView> {
  final _petitionerService = locator<PetitionerService>();

  Territory? _assignedTerritory;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadAssignedTerritory();
  }

  Future<void> _loadAssignedTerritory() async {
    setState(() => _isLoading = true);

    try {
      final territory = await _petitionerService.getAssignedTerritory();

      setState(() {
        _assignedTerritory = territory;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load territory data';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Territory', style: AppTextStyle.bold20),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: AppTextStyle.regular16.copyWith(color: Colors.red),
        ),
      );
    }

    if (_assignedTerritory == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mic_off,
              size: 64.r,
              color: Colors.grey,
            ),
            SizedBox(height: 16.h),
            Text(
              'No territory assigned',
              style: AppTextStyle.semibold18,
            ),
            SizedBox(height: 8.h),
            Text(
              'You do not have any territory assigned yet.',
              style: AppTextStyle.regular14.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Here you would implement your map view with the territory boundary
    // This is a placeholder - you'll need to implement the actual map with boundaries
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          color: AppColors.primary.withOpacity(0.1),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'You are viewing your assigned territory: ${_assignedTerritory!.name}',
                  style: AppTextStyle.regular14,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              'Map with territory boundaries will be displayed here',
              style: AppTextStyle.regular16,
            ),
            // In actual implementation, replace with your map widget displaying
            // boundaries from _assignedTerritory!.boundary.paths
          ),
        ),
      ],
    );
  }
}
