import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';

class HouseLegend extends StatelessWidget {
  const HouseLegend({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('House Status', style: AppTextStyle.semibold14),
          SizedBox(height: 8.h),
          _buildLegendItem('Signed', AppColors.green100),
          SizedBox(height: 2.h),
          _buildLegendItem('Partially Signed', AppColors.green.withOpacity(0.6)),
          SizedBox(height: 2.h),
          _buildLegendItem('Come Back', Colors.blue),
          SizedBox(height: 2.h),
          _buildLegendItem('Not Home', Colors.yellow),
          SizedBox(height: 2.h),
          _buildLegendItem('BAS', Colors.red),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
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
          style: AppTextStyle.regular12,
        ),
      ],
    );
  }
} 