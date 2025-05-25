import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/shared/constants/app_spacing.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:ballot_access_pro/ui/views/petitioner/bloc/personal_information_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ballot_access_pro/shared/widgets/territory_skeleton.dart';

class TerritoryView extends StatelessWidget {
  const TerritoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          PersonalInformationBloc()..add(const LoadPersonalInformation()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Territory',
            style: AppTextStyle.semibold16,
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<PersonalInformationBloc, PersonalInformationState>(
          builder: (context, state) {
            if (state.status == PersonalInformationStatus.loading) {
              return const TerritorySkeleton();
            }

            final petitioner = state.petitioner;
            if (petitioner == null) return const SizedBox();

            return SingleChildScrollView(
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
                            _buildStatusBadge(petitioner.status),
                            const Spacer(),
                            Text(
                              'Last Active: ${_formatDateTime(petitioner.lastActive)}',
                              style: AppTextStyle.regular12.copyWith(
                                color: AppColors.grey300,
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.v16(),
                        Text(
                          'Assigned Territories',
                          style: AppTextStyle.semibold16,
                        ),
                        AppSpacing.v12(),
                        ...petitioner.territories.map((territory) => Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: Text(
                                territory
                                    .id, // Extracting the id or name based on your Territory model
                                style: AppTextStyle.regular14,
                              ),
                            )),
                        AppSpacing.v16(),
                        _buildStatRow(
                          'Location',
                          'Lat: ${petitioner.location.latitude}, Long: ${petitioner.location.longitude}',
                        ),
                        AppSpacing.v8(),
                        _buildStatRow(
                          'Created',
                          _formatDateTime(petitioner.createdAt),
                        ),
                        AppSpacing.v8(),
                        _buildStatRow(
                          'Last Updated',
                          _formatDateTime(petitioner.updatedAt),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isActive = status.toLowerCase() == 'active';
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.success.withOpacity(0.1)
            : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        status.capitalize(),
        style: AppTextStyle.regular12.copyWith(
          color: isActive ? AppColors.success : AppColors.error,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return DateFormat('MMM dd, yyyy').format(dateTime);
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

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
