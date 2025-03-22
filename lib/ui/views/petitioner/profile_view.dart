import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:ballot_access_pro/shared/navigation/app_routes.dart';
import 'package:ballot_access_pro/shared/navigation/navigation_service.dart';
import 'package:ballot_access_pro/ui/views/petitioner/personal_information_view.dart';
import 'package:ballot_access_pro/ui/views/petitioner/territory_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/profile_bloc.dart';
import 'bloc/profile_state.dart';
import 'bloc/profile_event.dart';
import 'package:ballot_access_pro/shared/widgets/app_toast.dart';
import 'package:ballot_access_pro/shared/widgets/skeleton.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: AppTextStyle.bold20,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.failure) {
            AppToast.showErrorToast(state.error ?? 'Failed to load profile');
          }
        },
        builder: (context, state) {
          if (state.status == ProfileStatus.loading && state.petitioner == null) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  _buildProfileHeaderSkeleton(),
                  SizedBox(height: 24.h),
                  _buildStatisticsSkeleton(),
                  SizedBox(height: 24.h),
                  _buildMenuSkeleton(),
                ],
              ),
            );
          }

          if (state.petitioner == null) {
            return const Center(
              child: Text('No profile data available'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ProfileBloc>().add(const LoadProfile());
            },
            child: Stack(
              children: [
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      _buildProfileHeader(state),
                      SizedBox(height: 24.h),
                      _buildStatisticsSection(state),
                      SizedBox(height: 24.h),
                      _buildMenuSection(context),
                    ],
                  ),
                ),
                if (state.status == ProfileStatus.loading)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(ProfileState state) {
    final petitioner = state.petitioner!;
    final fullName = '${petitioner.firstName} ${petitioner.lastName}';
    final initials = '${petitioner.firstName[0]}${petitioner.lastName[0]}';
    final isActive = petitioner.status.toLowerCase() == 'active';

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
          if (petitioner.picture != null)
            CircleAvatar(
              radius: 50.r,
              backgroundImage: NetworkImage(petitioner.picture!),
            )
          else
            CircleAvatar(
              radius: 50.r,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                initials,
                style: AppTextStyle.bold24.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          SizedBox(height: 16.h),
          Text(
            fullName,
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
              color: isActive
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? Icons.check_circle : Icons.cancel,
                  color: isActive ? Colors.green : Colors.red,
                  size: 16.r,
                ),
                SizedBox(width: 4.w),
                Text(
                  petitioner.status,
                  style: AppTextStyle.regular12.copyWith(
                    color: isActive ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(ProfileState state) {
    final petitioner = state.petitioner!;
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
                  petitioner.housevisited.toString(),
                  Icons.home,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildStatItem(
                  'Success Rate',
                  '${petitioner.successRate.toStringAsFixed(1)}%',
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
                  petitioner.territories.isNotEmpty 
                      ? petitioner.territories.first 
                      : 'No Territory',
                  Icons.map,
                  Colors.orange,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildStatItem(
                  'Pending Revisits',
                  petitioner.pendingRevisits.toString(),
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

  Widget _buildMenuSection(BuildContext context) {
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PersonalInformationView(),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'Territory',
            Icons.map_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TerritoryView(),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'Sign Out',
            Icons.logout,
            color: Colors.red,
            onTap: () {
              context.read<ProfileBloc>().add(SignOut());
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

  Widget _buildProfileHeaderSkeleton() {
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
          Skeleton(
            height: 100.r,
            width: 100.r,
            borderRadius: 50.r,
          ),
          SizedBox(height: 16.h),
          Skeleton(width: 150.w),
          SizedBox(height: 8.h),
          Skeleton(width: 100.w),
          SizedBox(height: 16.h),
          Skeleton(width: 80.w, height: 30.h),
        ],
      ),
    );
  }

  Widget _buildStatisticsSkeleton() {
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
          Skeleton(width: 120.w),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: _buildStatItemSkeleton()),
              SizedBox(width: 16.w),
              Expanded(child: _buildStatItemSkeleton()),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: _buildStatItemSkeleton()),
              SizedBox(width: 16.w),
              Expanded(child: _buildStatItemSkeleton()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItemSkeleton() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton(height: 20.r, width: 20.r),
          SizedBox(height: 8.h),
          Skeleton(),
          SizedBox(height: 4.h),
          Skeleton(width: 60.w),
        ],
      ),
    );
  }

  Widget _buildMenuSkeleton() {
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
          _buildMenuItemSkeleton(),
          _buildDivider(),
          _buildMenuItemSkeleton(),
          _buildDivider(),
          _buildMenuItemSkeleton(),
        ],
      ),
    );
  }

  Widget _buildMenuItemSkeleton() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ),
      child: Row(
        children: [
          Skeleton(height: 24.r, width: 24.r),
          SizedBox(width: 16.w),
          Expanded(child: Skeleton()),
          SizedBox(width: 16.w),
          Skeleton(height: 24.r, width: 24.r),
        ],
      ),
    );
  }
}

class MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
} 