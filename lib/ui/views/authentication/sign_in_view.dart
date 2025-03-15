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
import 'package:ballot_access_pro/shared/constants/app_images.dart';
import 'package:ballot_access_pro/shared/utils/app_sizer.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool isFormValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      isFormValid = _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          FormValidators.validateEmail(_emailController.text) == null &&
          FormValidators.validatePassword(_passwordController.text) == null;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Implement actual sign in logic
      await Future.delayed(const Duration(seconds: 2));
      
      NavigationService.pushNamed(AppRoutes.petitionerHomeView);
    } catch (e) {
      // TODO: Handle sign in error
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AppDimension.init(context);
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSpacing.v24(),
                Center(
                  child: Image.asset(
                    AppImages.logo,
                    width: 150.w,
                    height: 150.h,
                  ),
                ),
                AppSpacing.v8(),
                Text(
                  'Welcome Back!',
                  style: AppTextStyle.bold24,
                  textAlign: TextAlign.center,
                ),
                AppSpacing.v8(),
                Text(
                  'Sign in to continue',
                  style: AppTextStyle.regular16.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.v20(),
                AppInput(
                  autoValidate: true,
                  controller: _emailController,
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: FormValidators.validateEmail,
                  inputColor: Colors.white,
                ),
                AppSpacing.v16(),
                AppInput(
                  autoValidate: true,
                  controller: _passwordController,
                  labelText: 'Password',
                  obscureText: true,
                  validator: FormValidators.validatePassword,
                  inputColor: Colors.white,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => NavigationService.pushNamed(
                      AppRoutes.forgotPasswordView,
                    ),
                    child: Text(
                      'Forgot Password?',
                      style: AppTextStyle.regular14.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                AppSpacing.v24(),
                AppButton(
                  text: 'Sign In',
                  loading: _isLoading,
                  onPressed: isFormValid
                      ? () {
                          if (_formKey.currentState!.validate()) {
                            _handleSignIn();
                          }
                        }
                      : null,
                  style: AppTextStyle.semibold16.copyWith(
                    color: Colors.white,
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
                        NavigationService.pushNamed(AppRoutes.signUpView);
                      },
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