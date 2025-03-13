import 'package:flutter/material.dart';
import 'package:ballot_access_pro/features/auth/presentation/pages/splash_screen_view.dart';
import 'package:ballot_access_pro/features/auth/presentation/pages/sign_in_view.dart';
import 'package:ballot_access_pro/features/auth/presentation/pages/sign_up_view.dart';

class AppRoutes {
  static const String splashScreenView = '/';
  static const String signInView = '/sign-in';
  static const String signUpView = '/sign-up';

  static String get initialRoute => splashScreenView;

  static Map<String, Widget Function(BuildContext)> routes = {
    splashScreenView: (context) => const SplashScreenView(),
    signInView: (context) => const SignInView(),
    signUpView: (context) => const SignUpView(),
  };
} 