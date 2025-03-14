import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/shared/constants/app_spacing.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PersonalInformationView extends StatelessWidget {
  const PersonalInformationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Information'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildInfoCard(
              title: 'Full Name',
              value: 'One Tew',
              icon: Icons.person,
            ),
            AppSpacing.v16(),
            _buildInfoCard(
              title: 'Phone',
              value: '09048484934',
              icon: Icons.phone,
            ),
            AppSpacing.v16(),
            _buildInfoCard(
              title: 'Email',
              value: 'com.arrikk@gmail.com',
              icon: Icons.email,
            ),
            AppSpacing.v16(),
            _buildInfoCard(
              title: 'Address',
              value: 'Petitioner Address in long than here',
              icon: Icons.location_on,
            ),
            AppSpacing.v16(),
            _buildInfoCard(
              title: 'Gender',
              value: 'Male',
              icon: Icons.person_outline,
            ),
            AppSpacing.v16(),
            _buildInfoCard(
              title: 'Country',
              value: 'Nigeria',
              icon: Icons.flag,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
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
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          AppSpacing.h16(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyle.regular12.copyWith(
                    color: Colors.grey,
                  ),
                ),
                AppSpacing.v4(),
                Text(
                  value,
                  style: AppTextStyle.semibold14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
