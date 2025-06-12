import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ballot_access_pro/services/fcm_service.dart';
import 'package:ballot_access_pro/core/locator.dart';

class PermissionHandler {
  static final FCMService _fcmService = locator<FCMService>();

  // Request all permissions needed by the app
  static Future<void> requestAllPermissions(BuildContext context) async {
    await requestLocationPermission(context);
    await requestNotificationPermission(context);
  }

  // Request location permission
  static Future<void> requestLocationPermission(BuildContext context) async {
    try {
      final status = await Permission.location.request();
      debugPrint('Location permission status: $status');
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
    }
  }

  // Request notification permission
  static Future<void> requestNotificationPermission(
    BuildContext context,
  ) async {
    try {
      if (Platform.isAndroid) {
        // For Android 13+ (API level 33+), need to request the notification permission
        final status = await Permission.notification.request();
        debugPrint('Notification permission status: $status');
      }

      // Use FCM to request notification permissions (works for both iOS and Android)
      await _fcmService.initialize();
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
    }
  }
}
