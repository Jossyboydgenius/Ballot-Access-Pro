import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/shared/constants/app_spacing.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ballot_access_pro/ui/views/petitioner/bloc/personal_information_bloc.dart';
import 'package:ballot_access_pro/models/petitioner_model.dart';
import 'package:ballot_access_pro/shared/widgets/personal_information_skeleton.dart';

class PersonalInformationView extends StatelessWidget {
  const PersonalInformationView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PersonalInformationBloc()..add(const LoadPersonalInformation()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Personal Information',
            style: AppTextStyle.semibold16,
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<PersonalInformationBloc, PersonalInformationState>(
          builder: (context, state) {
            if (state.status == PersonalInformationStatus.loading) {
              return const PersonalInformationSkeleton();
            }

            if (state.status == PersonalInformationStatus.failure) {
              return Center(child: Text(state.error ?? 'Failed to load data'));
            }

            final petitioner = state.petitioner;
            if (petitioner == null) return const SizedBox();

            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  _buildInfoCard(
                    title: 'Full Name',
                    value: '${petitioner.firstName} ${petitioner.lastName}',
                    icon: Icons.person,
                  ),
                  AppSpacing.v16(),
                  _buildInfoCard(
                    title: 'Phone',
                    value: petitioner.phone,
                    icon: Icons.phone,
                  ),
                  AppSpacing.v16(),
                  _buildInfoCard(
                    title: 'Email',
                    value: petitioner.email,
                    icon: Icons.email,
                  ),
                  AppSpacing.v16(),
                  _buildInfoCard(
                    title: 'Address',
                    value: petitioner.address,
                    icon: Icons.location_on,
                  ),
                  AppSpacing.v16(),
                  _buildInfoCard(
                    title: 'Gender',
                    value: petitioner.gender,
                    icon: Icons.person_outline,
                  ),
                  AppSpacing.v16(),
                  _buildInfoCard(
                    title: 'Country',
                    value: petitioner.country,
                    icon: Icons.flag,
                  ),
                ],
              ),
            );
          },
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
                    color: AppColors.grey300,
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
