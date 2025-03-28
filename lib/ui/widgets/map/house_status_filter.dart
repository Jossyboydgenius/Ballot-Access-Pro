import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';

class HouseStatusFilter extends StatelessWidget {
  final String selectedStatus;
  final Function(String) onStatusChanged;

  const HouseStatusFilter({
    Key? key,
    required this.selectedStatus,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    final isSelected = selectedStatus == label;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // If already selected, deselect it
          if (isSelected) {
            onStatusChanged('');
          } else {
            onStatusChanged(label);
          }
        },
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.r,
                height: 12.r,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: AppTextStyle.regular12.copyWith(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 