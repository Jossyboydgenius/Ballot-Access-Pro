import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:ballot_access_pro/shared/widgets/app_button.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  String selectedStatus = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // TODO: Implement Google Maps widget here
          Container(
            color: Colors.grey[200],
            child: const Center(
              child: Text('Google Maps will be integrated here'),
            ),
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
          // Add House Button
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
                  onPressed: () {
                    // TODO: Implement current location
                  },
                  child: const Icon(Icons.my_location, color: AppColors.primary),
                ),
                SizedBox(height: 8.h),
                FloatingActionButton.extended(
                  heroTag: 'add',
                  backgroundColor: AppColors.primary,
                  onPressed: () {
                    _showAddHouseBottomSheet(context);
                  },
                  icon: const Icon(
                    Icons.add_location_alt,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Add House',
                    style: TextStyle(
                      color: Colors.white,
                    ),
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
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16.r),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New House',
                style: AppTextStyle.bold20,
              ),
              SizedBox(height: 16.h),
              Text(
                'Current Location',
                style: AppTextStyle.regular14,
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.primary),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        '123 Main St, City, State 12345',
                        style: AppTextStyle.regular14,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Status',
                style: AppTextStyle.regular14,
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                children: [
                  _buildStatusChip('Signed', Colors.green),
                  _buildStatusChip('Come Back', Colors.orange),
                  _buildStatusChip('Not Home', Colors.blue),
                  _buildStatusChip('BAS', Colors.red),
                ],
              ),
              SizedBox(height: 24.h),
              AppButton(
                text: 'Add House',
                onPressed: () {
                  // TODO: Implement add house logic
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}