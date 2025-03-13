import 'package:ballot_access_pro/shared/widgets/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/navigation/app_routes.dart';
import 'package:ballot_access_pro/shared/navigation/navigation_service.dart';
import 'package:ballot_access_pro/shared/constants/app_spacing.dart';
import 'package:ballot_access_pro/shared/widgets/app_button.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';

class PasswordChangedView extends StatelessWidget {
  const PasswordChangedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIcons(
                icon: AppIconData.successmark,
                size: 100.r,
                color: AppColors.green100,
              ),
              AppSpacing.v24(),
              Text(
                'Password Changed!',
                style: AppTextStyle.bold20,
                textAlign: TextAlign.center,
              ),
              AppSpacing.v8(),
              Text(
                'Your password has been changed successfully',
                style: AppTextStyle.regular14,
                textAlign: TextAlign.center,
              ),
              AppSpacing.v32(),
              AppButton(
                text: 'Back to Sign In',
                onPressed: () {
                  NavigationService.pushReplacementNamed(AppRoutes.signInView);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
} 