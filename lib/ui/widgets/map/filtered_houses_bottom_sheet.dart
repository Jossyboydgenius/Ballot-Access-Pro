import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/models/territory_houses.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:intl/intl.dart';

class FilteredHousesBottomSheet extends StatelessWidget {
  final String status;
  final List<HouseVisit> houses;
  final Function(HouseVisit) onViewHouse;
  
  const FilteredHousesBottomSheet({
    Key? key,
    required this.status,
    required this.houses,
    required this.onViewHouse,
  }) : super(key: key);
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'signed':
        return AppColors.green100;
      case 'partially signed':
      case 'partially-signed':
        return AppColors.green.withOpacity(0.6);
      case 'comeback':
      case 'come back':
        return Colors.blue;
      case 'nothome':
      case 'not home':
        return Colors.yellow;
      case 'bas':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredHouses = houses.where((house) => 
      house.status.toLowerCase() == status.toLowerCase()).toList();
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Draggable indicator
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
          
          // Header
          Row(
            children: [
              Container(
                width: 16.r,
                height: 16.r,
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '$status Houses (${filteredHouses.length})',
                style: AppTextStyle.semibold18,
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // House list
          if (filteredHouses.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32.h),
                child: Text(
                  'No houses with status "$status"',
                  style: AppTextStyle.regular14.copyWith(color: Colors.grey[600]),
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: filteredHouses.length,
                separatorBuilder: (_, __) => Divider(height: 1.h),
                itemBuilder: (context, index) {
                  final house = filteredHouses[index];
                  return _buildHouseItem(context, house);
                },
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildHouseItem(BuildContext context, HouseVisit house) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12.r,
            height: 12.r,
            margin: EdgeInsets.only(top: 4.h),
            decoration: BoxDecoration(
              color: _getStatusColor(house.status),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  house.address,
                  style: AppTextStyle.semibold14,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  'Registered Voters: ${house.registeredVoters}',
                  style: AppTextStyle.regular12.copyWith(color: Colors.grey[600]),
                ),
                if (house.notes.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    'Notes: ${house.notes}',
                    style: AppTextStyle.regular12.copyWith(color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 2.h),
                Text(
                  'Last updated: ${DateFormat('MMM dd, yyyy HH:mm').format(house.updatedAt)}',
                  style: AppTextStyle.regular10.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the bottom sheet
              onViewHouse(house); // Show the house on the map
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.visibility, size: 16.r, color: AppColors.primary),
                SizedBox(width: 4.w),
                Text(
                  'View',
                  style: AppTextStyle.semibold12.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 