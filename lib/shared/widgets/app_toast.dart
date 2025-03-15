import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppToast {
  static void showErrorToast(String message) {
    _showCustomToast(
      message: message,
      accentColor: AppColors.red,
      iconBgColor: AppColors.bgRed,
      borderColor: AppColors.lightRed,
    );
  }

  static void showSuccessToast(String message) {
    _showCustomToast(
      message: message,
      accentColor: AppColors.green,
      iconBgColor: AppColors.bgGreen,
      borderColor: AppColors.lightGreen,
    );
  }

  static void _showCustomToast({
    required String message,
    required Color accentColor,
    required Color iconBgColor,
    required Color borderColor,
  }) {
    BotToast.showCustomNotification(
      duration: const Duration(seconds: 3),
      toastBuilder: (cancelFunc) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Left accent bar
                Container(
                  width: 4.w,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4.r),
                      bottomLeft: Radius.circular(4.r),
                    ),
                  ),
                ),
                // Main content
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(4.r),
                        bottomRight: Radius.circular(4.r),
                      ),
                      border: Border(
                        top: BorderSide(color: borderColor),
                        right: BorderSide(color: borderColor),
                        bottom: BorderSide(color: borderColor),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Close button with square container
                        Container(
                          width: 24.w,
                          height: 24.h,
                          decoration: BoxDecoration(
                            color: iconBgColor,
                            borderRadius: BorderRadius.circular(4.r),
                            border: Border.all(color: borderColor),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.close,
                              size: 16.r,
                              color: accentColor,
                            ),
                            onPressed: cancelFunc,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        // Message text
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message,
                                style: AppTextStyle.regular16.copyWith(
                                  color: Colors.black,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (message.contains('password')) ...[
                                SizedBox(height: 4.h),
                                Text(
                                  'Kindly input the right details.',
                                  style: AppTextStyle.regular16.copyWith(
                                    color: Colors.black,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 