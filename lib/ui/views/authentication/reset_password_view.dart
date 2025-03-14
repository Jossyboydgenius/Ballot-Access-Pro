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

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isFormValid = false;

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_validateForm);
    confirmPasswordController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      isFormValid = passwordController.text.isNotEmpty &&
          confirmPasswordController.text.isNotEmpty &&
          FormValidators.validatePassword(passwordController.text) == null &&
          FormValidators.checkIfPasswordSame(
            confirmPasswordController.text,
            passwordController.text,
          ) == null;
    });
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
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
                  'Reset Password',
                  style: AppTextStyle.bold20,
                ),
                AppSpacing.v8(),
                Text(
                  'Create a new password for your account',
                  style: AppTextStyle.regular14,
                ),
                AppSpacing.v32(),
                AppInput(
                  autoValidate: true,
                  labelText: 'New Password',
                  controller: passwordController,
                  obscureText: true,
                  validator: FormValidators.validatePassword,
                  inputColor: Colors.white,
                ),
                AppSpacing.v12(),
                AppInput(
                  autoValidate: true,
                  labelText: 'Confirm New Password',
                  controller: confirmPasswordController,
                  obscureText: true,
                  validator: (value) => FormValidators.checkIfPasswordSame(
                    value,
                    passwordController.text,
                  ),
                  inputColor: Colors.white,
                ),
                AppSpacing.v30(),
                AppButton(
                  text: 'Reset Password',
                  textColor: Colors.white,
                  style: AppTextStyle.semibold16.copyWith(color: Colors.white),
                  onPressed: isFormValid
                      ? () {
                          if (formKey.currentState!.validate()) {
                            NavigationService.pushNamed(AppRoutes.passwordChangedView);
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