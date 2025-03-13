import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:ballot_access_pro/shared/widgets/app_button.dart';
import 'package:ballot_access_pro/shared/constants/app_spacing.dart';

class AddHouseBottomSheet extends StatelessWidget {
  final String currentAddress;
  final Function(String) onStatusSelected;
  final VoidCallback onAddHouse;
  final String selectedStatus;

  const AddHouseBottomSheet({
    super.key,
    required this.currentAddress,
    required this.onStatusSelected,
    required this.onAddHouse,
    required this.selectedStatus,
  });

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
      onSelected: (bool selected) => onStatusSelected(selected ? label : ''),
      backgroundColor: Colors.white,
      selectedColor: color,
      checkmarkColor: Colors.white,
      side: BorderSide(color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            AppSpacing.v16(),
            Text(
              'Current Location',
              style: AppTextStyle.regular14,
            ),
            AppSpacing.v8(),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.primary),
                  AppSpacing.h8(),
                  Expanded(
                    child: Text(
                      currentAddress,
                      style: AppTextStyle.regular14,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.v16(),
            Text(
              'Status',
              style: AppTextStyle.regular14,
            ),
            AppSpacing.v8(),
            Wrap(
              spacing: 8.w,
              children: [
                _buildStatusChip('Signed', Colors.green),
                _buildStatusChip('Come Back', Colors.orange),
                _buildStatusChip('Not Home', Colors.blue),
                _buildStatusChip('BAS', Colors.red),
              ],
            ),
            AppSpacing.v24(),
            AppButton(
              text: 'Add House',
              onPressed: onAddHouse,
              style: AppTextStyle.semibold16.copyWith(color: Colors.white),
            ),
            AppSpacing.v16(),
          ],
        ),
      ),
    );
  }
}
