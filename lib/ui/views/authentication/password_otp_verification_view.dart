import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/navigation/app_routes.dart';
import 'package:ballot_access_pro/shared/navigation/navigation_service.dart';
import 'package:ballot_access_pro/shared/constants/app_spacing.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:ballot_access_pro/shared/widgets/app_back_button.dart';
import 'package:ballot_access_pro/shared/widgets/app_button.dart';
import 'package:pinput/pinput.dart';

class PasswordOtpVerificationView extends StatefulWidget {
  const PasswordOtpVerificationView({super.key});

  @override
  State<PasswordOtpVerificationView> createState() => _PasswordOtpVerificationViewState();
}

class _PasswordOtpVerificationViewState extends State<PasswordOtpVerificationView> {
  final TextEditingController otpController = TextEditingController();
  bool isFormValid = false;
  bool isVerifying = false;
  bool canResend = false;
  int resendTimer = 60;

  @override
  void initState() {
    super.initState();
    otpController.addListener(_validateForm);
    _startResendTimer();
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && resendTimer > 0) {
        setState(() {
          resendTimer--;
        });
        _startResendTimer();
      } else if (mounted) {
        setState(() {
          canResend = true;
        });
      }
    });
  }

  void _handleResendCode() {
    if (!canResend) return;
    
    setState(() {
      canResend = false;
      resendTimer = 60;
    });
    
    // TODO: Implement resend code logic
    
    _startResendTimer();
  }

  void _validateForm() {
    setState(() {
      isFormValid = otpController.text.length == 6;
    });
  }

  void _handleVerification() {
    if (otpController.text.length != 6) return;

    setState(() {
      isVerifying = true;
    });

    // Simulate verification delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        NavigationService.pushNamed(AppRoutes.resetPasswordView);
      }
    });
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 45.w,
      height: 45.h,
      textStyle: AppTextStyle.regular16,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey200),
        borderRadius: BorderRadius.circular(8.r),
      ),
    );

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
              Center(
                child: Pinput(
                  length: 6,
                  controller: otpController,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(color: AppColors.primary),
                    ),
                  ),
                  onCompleted: (_) => _handleVerification(),
                ),
              ),
              AppSpacing.v32(),
              AppButton(
                text: isVerifying ? 'Verifying...' : 'Verify',
                textColor: Colors.white,
                style: AppTextStyle.semibold16.copyWith(color: Colors.white),
                onPressed: isVerifying ? null : _handleVerification,
              ),
              AppSpacing.v24(),
              Center(
                child: TextButton(
                  onPressed: canResend ? _handleResendCode : null,
                  child: Text(
                    canResend
                        ? 'Resend Code'
                        : 'Resend code in ${resendTimer}s',
                    style: AppTextStyle.regular14.copyWith(
                      color: canResend ? AppColors.primary : AppColors.grey300,
                    ),
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