import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/navigation/app_routes.dart';
import 'package:ballot_access_pro/shared/navigation/navigation_service.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/shared/constants/app_spacing.dart';
import 'package:ballot_access_pro/shared/utils/form_validator.dart';
import 'package:ballot_access_pro/shared/widgets/app_button.dart';
import 'package:ballot_access_pro/shared/widgets/input/app_input.dart';
import 'package:ballot_access_pro/shared/widgets/app_rich_text.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.v24(),
                  Text(
                    'Welcome back! Sign in to your account',
                    style: AppTextStyle.bold20,
                  ),
                  AppSpacing.v32(),
                  AppInput(
                    autoValidate: true,
                    labelText: 'Email',
                    controller: emailController,
                    validator: FormValidators.validateEmail,
                    inputColor: Colors.white,
                  ),
                  AppSpacing.v12(),
                  AppInput(
                    autoValidate: true,
                    labelText: 'Password',
                    controller: passwordController,
                    obscureText: true,
                    validator: FormValidators.validatePassword,
                    inputColor: Colors.white,
                  ),
                  AppSpacing.v30(),
                  AppButton(
                    text: 'Sign in',
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        // TODO: Implement sign in logic
                      }
                    },
                  ),
                  AppSpacing.v16(),
                  Center(
                    child: TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      onPressed: () {
                        // TODO: Implement forgot password
                      },
                      child: Text(
                        'Forgot Password?',
                        style: AppTextStyle.semibold14.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.v45(),
                  Center(
                    child: AppRichText(
                      title: "Don't have an account? ",
                      subTitle: "Sign up",
                      titleStyle: AppTextStyle.regular14,
                      subTitleStyle: AppTextStyle.semibold14.copyWith(
                        color: AppColors.primary,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          NavigationService.pushReplacementNamed(AppRoutes.signUpView);
                        },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 