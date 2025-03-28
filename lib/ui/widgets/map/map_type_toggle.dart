import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';

class MapTypeToggle extends StatelessWidget {
  final MapType currentMapType;
  final Function(MapType) onMapTypeChanged;

  const MapTypeToggle({
    Key? key,
    required this.currentMapType,
    required this.onMapTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: () {
              onMapTypeChanged(MapType.normal);
            },
            child: Text(
              'Map',
              style: AppTextStyle.regular14.copyWith(
                color: currentMapType == MapType.normal 
                    ? AppColors.primary 
                    : Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              onMapTypeChanged(MapType.satellite);
            },
            child: Text(
              'Satellite',
              style: AppTextStyle.regular14.copyWith(
                color: currentMapType == MapType.satellite 
                    ? AppColors.primary 
                    : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 