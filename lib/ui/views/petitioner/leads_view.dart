import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:ballot_access_pro/shared/widgets/app_input.dart';
import 'package:ballot_access_pro/ui/views/petitioner/widgets/add_lead_bottom_sheet.dart';
import 'package:ballot_access_pro/shared/constants/app_spacing.dart';

class LeadsView extends StatefulWidget {
  const LeadsView({super.key});

  @override
  State<LeadsView> createState() => _LeadsViewState();
}

class _LeadsViewState extends State<LeadsView> {
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Leads',
          style: AppTextStyle.bold20,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: AppInput(
              controller: searchController,
              hintText: 'Search leads...',
              keyboardType: TextInputType.text,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: 2, // Replace with actual leads count
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.only(bottom: 16.h),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primary,
                              child: Text(
                                'JD',
                                style: AppTextStyle.regular14.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            AppSpacing.h12(),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'John Doe',
                                    style: AppTextStyle.semibold16,
                                  ),
                                  Text(
                                    '123 Main St, City, State',
                                    style: AppTextStyle.regular14,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                'Interested',
                                style: AppTextStyle.regular12.copyWith(
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.v12(),
                        Text(
                          'Notes: Interested in supporting the campaign. Follow up next week.',
                          style: AppTextStyle.regular14,
                        ),
                        AppSpacing.v12(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                // TODO: Implement call functionality
                              },
                              icon: const Icon(
                                Icons.phone,
                                color: AppColors.primary,
                              ),
                              label: Text(
                                'Call',
                                style: AppTextStyle.regular14.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            AppSpacing.h16(),
                            TextButton.icon(
                              onPressed: () {
                                // TODO: Implement edit functionality
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: AppColors.primary,
                              ),
                              label: Text(
                                'Edit',
                                style: AppTextStyle.regular14.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => AddLeadBottomSheet(
              onAddLead: (name, address, phone, notes) {
                // TODO: Implement add lead functionality
              },
            ),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Lead',
          style: AppTextStyle.semibold16.copyWith(color: Colors.white),
        ),
      ),
    );
  }
} 