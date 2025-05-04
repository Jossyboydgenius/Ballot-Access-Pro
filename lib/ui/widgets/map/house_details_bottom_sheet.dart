import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:ballot_access_pro/models/territory_houses.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';

class HouseDetailsBottomSheet extends StatelessWidget {
  final HouseVisit house;
  final Function(HouseVisit) onUpdateTap;

  const HouseDetailsBottomSheet({
    Key? key,
    required this.house,
    required this.onUpdateTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 5.h,
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.5.r),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  house.address,
                  style: AppTextStyle.semibold16,
                ),
              ),
              // Update button
              TextButton(
                onPressed: () => onUpdateTap(house),
                style: TextButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, size: 16.r, color: AppColors.primary),
                    SizedBox(width: 4.w),
                    Text(
                      'Update',
                      style: AppTextStyle.semibold12
                          .copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Status: ${house.status.toUpperCase()}',
            style: AppTextStyle.regular14.copyWith(
              color: house.statusColor.startsWith('#')
                  ? Color(int.parse('0xFF${house.statusColor.substring(1)}'))
                  : Colors.black,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Registered Voters: ${house.registeredVoters}',
            style: AppTextStyle.regular14,
          ),
          if (house.notes.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              'Notes: ${house.notes}',
              style: AppTextStyle.regular14,
            ),
          ],
          SizedBox(height: 8.h),
          Text(
            'Petitioner: ${house.petitioner.firstName} ${house.petitioner.lastName}',
            style: AppTextStyle.regular14,
          ),
          SizedBox(height: 8.h),
          Text(
            'Last Updated: ${DateFormat('MMM dd, yyyy HH:mm').format(house.updatedAt)}',
            style: AppTextStyle.regular12.copyWith(color: Colors.grey),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
