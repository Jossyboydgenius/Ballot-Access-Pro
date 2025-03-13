import 'package:flutter/material.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/shared/navigation/navigation_service.dart';

class AppSnackbar {
  static void showSnackBar({required String message}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: AppColors.primary,
    );
    ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!)
        .showSnackBar(snackBar);
  }

  static void showErrorSnackBar({required String message}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: AppColors.red,
    );
    ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!)
        .showSnackBar(snackBar);
  }
} 