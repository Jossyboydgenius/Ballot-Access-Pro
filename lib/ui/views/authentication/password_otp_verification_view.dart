import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/navigation/app_routes.dart';
import 'package:ballot_access_pro/shared/navigation/navigation_service.dart';
import 'package:ballot_access_pro/shared/constants/app_spacing.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:ballot_access_pro/shared/widgets/app_back_button.dart';
import 'package:ballot_access_pro/shared/widgets/app_button.dart';
import 'package:ballot_access_pro/shared/widgets/input/pin_code_field.dart';

class PasswordOtpVerificationView extends StatefulWidget {
  const PasswordOtpVerificationView({super.key});

  @override
  State<PasswordOtpVerificationView> createState() => _PasswordOtpVerificationViewState();
}

class _PasswordOtpVerificationViewState extends State<PasswordOtpVerificationView> {
  final TextEditingController otpController = TextEditingController();
  bool isFormValid = false;

  @override
  void initState() {
    super.initState();
    otpController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      isFormValid = otpController.text.length == 6;
    });
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.v24(),
              const AppBackButton(),
              AppSpacing.v32(),
              Text(
                'Verify Email',
                style: AppTextStyle.bold20,
              ),
              AppSpacing.v8(),
              Text(
                'Enter the 6-digit code sent to your email',
                style: AppTextStyle.regular14,
              ),
              AppSpacing.v32(),
              PinCodeField(
                controller: otpController,
                onChanged: (value) {
                  _validateForm();
                },
              ),
              AppSpacing.v30(),
              AppButton(
                text: 'Verify',
                onPressed: isFormValid
                    ? () {
                        NavigationService.pushNamed(AppRoutes.resetPasswordView);
                      }
                    : null,
              ),
              AppSpacing.v24(),
              Center(
                child: TextButton(
                  onPressed: () {
                    // TODO: Implement resend code logic
                  },
                  child: Text(
                    'Resend Code',
                    style: AppTextStyle.semibold14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 