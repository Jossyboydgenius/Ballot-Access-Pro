import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PersonalInformationSkeleton extends StatelessWidget {
  const PersonalInformationSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: List.generate(
          6,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: _buildSkeletonCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80.w,
                    height: 12.h,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    width: 200.w,
                    height: 16.h,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 