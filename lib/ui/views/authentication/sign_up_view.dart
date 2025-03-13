import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/navigation/navigation_service.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/shared/constants/app_spacing.dart';
import 'package:ballot_access_pro/shared/utils/form_validator.dart';
import 'package:ballot_access_pro/shared/widgets/app_button.dart';
import 'package:ballot_access_pro/shared/widgets/input/app_input.dart';
import 'package:ballot_access_pro/shared/widgets/app_rich_text.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isFormValid = false;

  @override
  void initState() {
    super.initState();
    nameController.addListener(_validateForm);
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
    confirmPasswordController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      isFormValid = nameController.text.isNotEmpty &&
                   emailController.text.isNotEmpty &&
                   passwordController.text.isNotEmpty &&
                   confirmPasswordController.text.isNotEmpty &&
                   FormValidators.isNameValid(nameController.text) == null &&
                   FormValidators.validateEmail(emailController.text) == null &&
                   FormValidators.validatePassword(passwordController.text) == null &&
                   FormValidators.checkIfPasswordSame(
                     confirmPasswordController.text,
                     passwordController.text,
                   ) == null;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.v24(),
                  Text(
                    'Create an account to get started',
                    style: AppTextStyle.bold20,
                  ),
                  AppSpacing.v32(),
                  AppInput(
                    autoValidate: true,
                    labelText: 'Full Name',
                    controller: nameController,
                    validator: FormValidators.isNameValid,
                    inputColor: Colors.white,
                  ),
                  AppSpacing.v12(),
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
                  AppSpacing.v12(),
                  AppInput(
                    autoValidate: true,
                    labelText: 'Confirm Password',
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
                    text: 'Sign up',
                    onPressed: isFormValid
                        ? () {
                            if (formKey.currentState!.validate()) {
                              // TODO: Implement sign up logic
                            }
                          }
                        : null,
                  ),
                  AppSpacing.v45(),
                  Center(
                    child: AppRichText(
                      title: "Already have an account? ",
                      subTitle: "Sign in",
                      titleStyle: AppTextStyle.regular14,
                      subTitleStyle: AppTextStyle.semibold14.copyWith(
                        color: AppColors.primary,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          NavigationService.pushReplacementNamed('/sign-in');
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