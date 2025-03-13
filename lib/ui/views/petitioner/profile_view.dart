import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:ballot_access_pro/shared/navigation/app_routes.dart';
import 'package:ballot_access_pro/shared/navigation/navigation_service.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: AppTextStyle.bold20,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildProfileHeader(),
            SizedBox(height: 24.h),
            _buildStatisticsSection(),
            SizedBox(height: 24.h),
            _buildMenuSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50.r,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              'JD',
              style: AppTextStyle.bold24.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'John Doe',
            style: AppTextStyle.bold20,
          ),
          SizedBox(height: 4.h),
          Text(
            'Petitioner',
            style: AppTextStyle.regular14.copyWith(
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 6.h,
            ),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 16.r,
                ),
                SizedBox(width: 4.w),
                Text(
                  'Active',
                  style: AppTextStyle.regular12.copyWith(
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Statistics',
            style: AppTextStyle.semibold16,
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Houses Visited',
                  '1,234',
                  Icons.home,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildStatItem(
                  'Success Rate',
                  '75%',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Territory',
                  'Zone A',
                  Icons.map,
                  Colors.orange,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildStatItem(
                  'Active Days',
                  '45',
                  Icons.calendar_today,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20.r),
          SizedBox(height: 8.h),
          Text(
            value,
            style: AppTextStyle.bold16,
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: AppTextStyle.regular12.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            'Personal Information',
            Icons.person_outline,
            onTap: () {
              // TODO: Navigate to personal information screen
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'Territory Settings',
            Icons.map_outlined,
            onTap: () {
              // TODO: Navigate to territory settings screen
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'Notifications',
            Icons.notifications_outlined,
            onTap: () {
              // TODO: Navigate to notifications screen
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'Help & Support',
            Icons.help_outline,
            onTap: () {
              // TODO: Navigate to help screen
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'Sign Out',
            Icons.logout,
            color: Colors.red,
            onTap: () {
              NavigationService.pushReplacementNamed(AppRoutes.signInView);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    String title,
    IconData icon, {
    Color? color,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? Colors.grey[600],
      ),
      title: Text(
        title,
        style: AppTextStyle.regular14.copyWith(
          color: color ?? Colors.black,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
    );
  }
} 