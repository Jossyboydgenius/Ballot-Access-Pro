import 'package:ballot_access_pro/ui/views/admin/admin_dashboard_view.dart';
import 'package:ballot_access_pro/ui/views/authentication/email_verification_view.dart';
import 'package:ballot_access_pro/ui/views/petitioner/petitioner_home_view.dart';
import 'package:ballot_access_pro/ui/views/splash_screen_view.dart';
import 'package:flutter/material.dart';
import 'package:ballot_access_pro/ui/views/authentication/sign_in_view.dart';
import 'package:ballot_access_pro/ui/views/authentication/sign_up_view.dart';
import 'package:ballot_access_pro/ui/views/authentication/forgot_password_view.dart';
import 'package:ballot_access_pro/ui/views/authentication/password_otp_verification_view.dart';
import 'package:ballot_access_pro/ui/views/authentication/reset_password_view.dart';
import 'package:ballot_access_pro/ui/views/authentication/password_changed_view.dart';

class AppRoutes {
  // Authentication Routes
  static const String splashScreenView = '/';
  static const String signInView = '/sign-in';
  static const String signUpView = '/sign-up';
  static const String forgotPasswordView = '/forgot-password';
  static const String passwordOtpVerificationView = '/password-otp-verification';
  static const String resetPasswordView = '/reset-password';
  static const String passwordChangedView = '/password-changed';

  // Role-based Routes
  static const String adminDashboardView = '/admin/dashboard';
  static const String petitionerHomeView = '/petitioner/home';
  static const String emailVerificationView = '/email-verification';  

  static const String initialRoute = splashScreenView;

  static Map<String, Widget Function(BuildContext)> routes = {
    splashScreenView: (context) => const SplashScreenView(),
    signInView: (context) => const SignInView(),
    signUpView: (context) => const SignUpView(),
    forgotPasswordView: (context) => const ForgotPasswordView(),
    passwordOtpVerificationView: (context) => const PasswordOtpVerificationView(),
    resetPasswordView: (context) => const ResetPasswordView(),
    passwordChangedView: (context) => const PasswordChangedView(),
    adminDashboardView: (context) => const AdminDashboardView(),
    petitionerHomeView: (context) => const PetitionerHomeView(),
    emailVerificationView: (context) => const EmailVerificationView(
          email: '',
          userId: '',
        ),
  };
} 