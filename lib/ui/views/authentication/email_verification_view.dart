import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/navigation/app_routes.dart';
import 'package:ballot_access_pro/shared/navigation/navigation_service.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/shared/constants/app_spacing.dart';
import 'package:ballot_access_pro/shared/widgets/app_button.dart';
import 'package:ballot_access_pro/shared/widgets/app_back_button.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:ballot_access_pro/shared/widgets/app_toast.dart';
import 'package:pinput/pinput.dart';
import 'bloc/email_verification_bloc.dart';
import 'bloc/email_verification_event.dart';
import 'bloc/email_verification_state.dart';

class EmailVerificationView extends StatefulWidget {
  final String email;
  final String userId;

  const EmailVerificationView({
    Key? key,
    required this.email,
    required this.userId,
  }) : super(key: key);

  @override
  State<EmailVerificationView> createState() => _EmailVerificationViewState();
}

class _EmailVerificationViewState extends State<EmailVerificationView> {
  final pinController = TextEditingController();
  bool isVerifying = false;
  bool canResend = false;
  int resendTimer = 60;

  @override
  void initState() {
    super.initState();
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
    
    context.read<EmailVerificationBloc>().add(
          ResendEmailVerification(userId: widget.userId),
        );
    
    _startResendTimer();
  }

  void _handleVerification() {
    if (pinController.text.length != 6) return;

    context.read<EmailVerificationBloc>().add(
          VerifyEmailSubmitted(
            code: pinController.text,
            userId: widget.userId,
          ),
        );
  }

  @override
  void dispose() {
    pinController.dispose();
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

    return BlocListener<EmailVerificationBloc, EmailVerificationState>(
      listener: (context, state) {
        // Handle verification status
        if (state.verificationStatus == EmailVerificationStatus.loading) {
          setState(() => isVerifying = true);
        } else {
          setState(() => isVerifying = false);
        }

        if (state.verificationStatus == EmailVerificationStatus.success) {
          NavigationService.pushReplacementNamed(AppRoutes.petitionerHomeView);
        }

        if (state.verificationStatus == EmailVerificationStatus.failure) {
          AppToast.showErrorToast(state.errorMessage ?? 'Verification failed');
        }

        // Handle resend status
        if (state.resendStatus == ResendEmailStatus.success) {
          AppToast.showSuccessToast('Verification code sent to your email');
        }

        if (state.resendStatus == ResendEmailStatus.failure) {
          AppToast.showErrorToast(
            state.resendErrorMessage ?? 'Failed to resend verification code',
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 22.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpacing.v12(),
                const AppBackButton(),
                AppSpacing.v16(),
                Text(
                  'Verify your email',
                  style: AppTextStyle.bold24,
                ),
                AppSpacing.v8(),
                Text(
                  'Please enter the 6-digit code sent to',
                  style: AppTextStyle.regular14,
                ),
                AppSpacing.v4(),
                Text(
                  widget.email,
                  style: AppTextStyle.semibold14,
                ),
                AppSpacing.v32(),
                Center(
                  child: Pinput(
                    length: 6,
                    controller: pinController,
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
      ),
    );
  }
} 