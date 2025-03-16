import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/navigation/app_routes.dart';
import 'package:ballot_access_pro/shared/navigation/navigation_service.dart';
import 'package:ballot_access_pro/shared/constants/app_images.dart';
import 'package:ballot_access_pro/services/local_storage_service.dart';
import 'package:ballot_access_pro/core/locator.dart';

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({super.key});

  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> {
  final LocalStorageService _storageService = locator<LocalStorageService>();

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    final token = await _storageService.getStorageValue(LocalStorageKeys.accessToken);
    
    if (token != null) {
      NavigationService.pushReplacementNamed(AppRoutes.petitionerHomeView);
    } else {
      NavigationService.pushReplacementNamed(AppRoutes.signInView);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          AppImages.logo,
          width: 200.w,
          height: 200.h,
        ),
      ),
    );
  }
} 