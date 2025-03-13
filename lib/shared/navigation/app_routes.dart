import 'package:ballot_access_pro/ui/views/admin/admin_dashboard_view.dart';
import 'package:ballot_access_pro/ui/views/petitioner/petitioner_home_view.dart';
import 'package:ballot_access_pro/ui/views/splash_screen_view.dart';
import 'package:flutter/material.dart';
import 'package:ballot_access_pro/ui/views/authentication/sign_in_view.dart';
import 'package:ballot_access_pro/ui/views/authentication/sign_up_view.dart';
import 'package:ballot_access_pro/ui/views/authentication/forgot_password_view.dart';
import 'package:ballot_access_pro/ui/views/authentication/password_otp_verification_view.dart';
import 'package:ballot_access_pro/ui/views/authentication/reset_password_view.dart';
import 'package:ballot_access_pro/ui/views/authentication/password_changed_view.dart';
// import 'package:ballot_access_pro/ui/views/home/home_view.dart';

class AppRoutes {
  // Authentication Routes
  static const String splashScreenView = '/';
  static const String signInView = '/sign-in';
  static const String signUpView = '/sign-up';
  static const String forgotPasswordView = '/forgot-password';
  static const String passwordOtpVerificationView = '/password-otp-verification';
  static const String resetPasswordView = '/reset-password';
  static const String passwordChangedView = '/password-changed';
  // static const String homeView = '/home';
  
  // Role-based Routes
  static const String adminDashboardView = '/admin/dashboard';
  static const String petitionerHomeView = '/petitioner/home';

  static const String initialRoute = splashScreenView;

  static Map<String, Widget Function(BuildContext)> routes = {
    splashScreenView: (context) => const SplashScreenView(),
    signInView: (context) => const SignInView(),
    signUpView: (context) => const SignUpView(),
    forgotPasswordView: (context) => const ForgotPasswordView(),
    passwordOtpVerificationView: (context) => const PasswordOtpVerificationView(),
    resetPasswordView: (context) => const ResetPasswordView(),
    passwordChangedView: (context) => const PasswordChangedView(),
    // homeView: (context) => const HomeView(),
    adminDashboardView: (context) => const AdminDashboardView(),
    petitionerHomeView: (context) => const PetitionerHomeView(),
  };

  // Helper method to navigate based on user role
  static String getHomeRouteForRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return adminDashboardView;
      case 'petitioner':
        return petitionerHomeView;
      default:
        return signInView;
    }
  }
} 