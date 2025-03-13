import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/navigation/app_routes.dart';
import 'package:ballot_access_pro/shared/navigation/navigation_service.dart';
import 'package:ballot_access_pro/shared/constants/app_spacing.dart';
import 'package:ballot_access_pro/shared/utils/form_validator.dart';
import 'package:ballot_access_pro/shared/widgets/app_button.dart';
import 'package:ballot_access_pro/shared/widgets/input/app_input.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:ballot_access_pro/shared/widgets/app_back_button.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  bool isFormValid = false;

  @override
  void initState() {
    super.initState();
    emailController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      isFormValid = emailController.text.isNotEmpty &&
          FormValidators.validateEmail(emailController.text) == null;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.w),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpacing.v24(),
                const AppBackButton(),
                AppSpacing.v32(),
                Text(
                  'Forgot Password',
                  style: AppTextStyle.bold20,
                ),
                AppSpacing.v8(),
                Text(
                  'Enter your email address to receive a verification code',
                  style: AppTextStyle.regular14,
                ),
                AppSpacing.v32(),
                AppInput(
                  autoValidate: true,
                  labelText: 'Email',
                  controller: emailController,
                  validator: FormValidators.validateEmail,
                  inputColor: Colors.white,
                ),
                AppSpacing.v30(),
                AppButton(
                  text: 'Send Code',
                  onPressed: isFormValid
                      ? () {
                          if (formKey.currentState!.validate()) {
                            NavigationService.pushNamed(AppRoutes.passwordOtpVerificationView);
                          }
                        }
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 