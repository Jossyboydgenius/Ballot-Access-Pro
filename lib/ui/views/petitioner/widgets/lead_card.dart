import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:intl/intl.dart';
import 'package:ballot_access_pro/models/lead_model.dart';

class LeadCard extends StatelessWidget {
  final LeadModel lead;

  const LeadCard({
    Key? key,
    required this.lead,
  }) : super(key: key);

  String get fullName => '${lead.firstName} ${lead.lastName}';
  String get initials =>
      '${lead.firstName[0]}${lead.lastName[0]}'.toUpperCase();
  String get formattedDate => DateFormat('MMM dd, yyyy').format(lead.createdAt);

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toLowerCase()) {
      case 'comeback':
        return Colors.orange;
      case 'not home':
        return Colors.blue;
      case 'not signed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
                    initials,
                    style:
                        AppTextStyle.semibold16.copyWith(color: Colors.white),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: AppTextStyle.semibold16,
                      ),
                      if (lead.address != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          lead.address!,
                          style: AppTextStyle.regular14.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (lead.visit?.status != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _getStatusColor(lead.visit?.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      lead.visit!.status.toUpperCase(),
                      style: AppTextStyle.medium14.copyWith(
                        color: _getStatusColor(lead.visit?.status),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            if (lead.phone.isNotEmpty)
              Text(
                'Phone: ${lead.phone}',
                style: AppTextStyle.regular14,
              ),
            if (lead.email.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                'Email: ${lead.email}',
                style: AppTextStyle.regular14,
              ),
            ],
            if (lead.note != null) ...[
              SizedBox(height: 4.h),
              Text(
                'Note: ${lead.note}',
                style: AppTextStyle.regular14,
              ),
            ],
            SizedBox(height: 8.h),
            Text(
              'Created: $formattedDate',
              style: AppTextStyle.regular12.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
