import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/shared/constants/app_spacing.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TerritoryView extends StatelessWidget {
  const TerritoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Territory',
          style: AppTextStyle.semibold16,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Project',
              style: AppTextStyle.bold20,
            ),
            AppSpacing.v16(),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'Active',
                          style: AppTextStyle.regular12.copyWith(
                            color: AppColors.green100,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Started: Jan 15, 2024',
                        style: AppTextStyle.regular12.copyWith(
                          color: AppColors.grey300,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.v12(),
                  Text(
                    'Project Name',
                    style: AppTextStyle.semibold16,
                  ),
                  AppSpacing.v8(),
                  Text(
                    'Project description and details go here...',
                    style: AppTextStyle.regular14,
                  ),
                  AppSpacing.v16(),
                  _buildStatRow('Territory', 'North Central'),
                  AppSpacing.v8(),
                  _buildStatRow('State', 'Lagos'),
                  AppSpacing.v8(),
                  _buildStatRow('Local Government', 'Ikeja'),
                  AppSpacing.v8(),
                  _buildStatRow('Target Houses', '1000'),
                  AppSpacing.v8(),
                  _buildStatRow('Houses Visited', '250'),
                  AppSpacing.v8(),
                  _buildStatRow('Success Rate', '75%'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyle.regular14.copyWith(
            color: AppColors.grey300,
          ),
        ),
        Text(
          value,
          style: AppTextStyle.semibold14,
        ),
      ],
    );
  }
}
