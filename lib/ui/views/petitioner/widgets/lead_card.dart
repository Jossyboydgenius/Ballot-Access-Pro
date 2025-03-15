import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';

class LeadCard extends StatelessWidget {
  final String name;
  final String address;
  // final String status; // Commented out as requested
  // final Color statusColor; // Commented out as requested
  // final VoidCallback onCall; // Commented out as requested
  // final VoidCallback onEdit; // Commented out as requested

  const LeadCard({
    Key? key,
    required this.name,
    required this.address,
    // required this.status, // Commented out as requested
    // required this.statusColor, // Commented out as requested
    // required this.onCall, // Commented out as requested
    // required this.onEdit, // Commented out as requested
  }) : super(key: key);

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
                  backgroundColor: Colors.blue,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: AppTextStyle.semibold16.copyWith(color: Colors.white),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyle.semibold16,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        address,
                        style: AppTextStyle.regular14.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Commented out status indicator
                /*Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    status,
                    style: AppTextStyle.medium14.copyWith(
                      color: statusColor,
                    ),
                  ),
                ),*/
              ],
            ),
            // Commented out action buttons
            /*SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onCall,
                  icon: Icon(Icons.phone, color: Colors.blue),
                  label: Text(
                    'Call',
                    style: AppTextStyle.medium14.copyWith(color: Colors.blue),
                  ),
                ),
                SizedBox(width: 16.w),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit, color: Colors.blue),
                  label: Text(
                    'Edit',
                    style: AppTextStyle.medium14.copyWith(color: Colors.blue),
                  ),
                ),
              ],
            ),*/
          ],
        ),
      ),
    );
  }
} 