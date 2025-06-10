import 'dart:convert';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/locator.dart';
import '../core/flavor_config.dart';
import '../services/local_storage_service.dart';

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final AppFlavorConfig _config = locator<AppFlavorConfig>();

  // Initialize FCM service
  Future<void> initialize() async {
    try {
      // Request permission for iOS - wrap in try-catch to handle potential issues
      NotificationSettings settings;
      try {
        settings = await _firebaseMessaging
            .requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        )
            .timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint('FCM: Permission request timed out');
            throw TimeoutException('Permission request timed out');
          },
        );
        debugPrint(
            'FCM: User granted permission: ${settings.authorizationStatus}');
      } catch (e) {
        debugPrint('FCM: Error requesting permission: $e');
        // Continue without notifications permission
        return;
      }

      // Get the token with proper error handling
      String? token;
      try {
        token = await _firebaseMessaging.getToken().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint('FCM: Token retrieval timed out');
            return null;
          },
        );
      } catch (e) {
        debugPrint('FCM: Error getting token: $e');
        return; // Exit initialization if token can't be retrieved
      }

      if (token != null) {
        debugPrint('FCM: Token: $token');
        // Save token to storage for easy access
        try {
          await _storageService.saveStorageValue(
              LocalStorageKeys.fcmToken, token);

          // Update token on server in background without waiting
          unawaited(updateTokenOnServer(token).catchError((e) {
            debugPrint('FCM: Error updating token on server: $e');
            return false; // Return a value to satisfy Future<bool>
          }));
        } catch (e) {
          debugPrint('FCM: Error saving token to storage: $e');
        }
      }

      // Listen for token refresh
      try {
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          debugPrint('FCM: Token refreshed: $newToken');

          // Use unawaited to avoid waiting for these futures
          unawaited(_storageService
              .saveStorageValue(LocalStorageKeys.fcmToken, newToken)
              .catchError((e) {
            debugPrint('FCM: Error saving refreshed token: $e');
            return null; // Return a value for the Future
          }));

          unawaited(updateTokenOnServer(newToken).catchError((e) {
            debugPrint('FCM: Error updating refreshed token on server: $e');
            return false; // Return a value for the Future<bool>
          }));
        });
      } catch (e) {
        debugPrint('FCM: Error setting up token refresh listener: $e');
      }

      // Set up foreground message handler
      try {
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('FCM: Got a message in foreground!');
          debugPrint('FCM: Message data: ${message.data}');

          if (message.notification != null) {
            debugPrint(
                'FCM: Message notification: ${message.notification!.title}');
            debugPrint(
                'FCM: Message notification: ${message.notification!.body}');
          }
        });
      } catch (e) {
        debugPrint('FCM: Error setting up message handler: $e');
      }
    } catch (e) {
      debugPrint('FCM: Error during initialization: $e');
      // Don't rethrow - allow app to continue without FCM
    }
  }

  // Update FCM token on server
  Future<bool> updateTokenOnServer(String token) async {
    try {
      // Get the current user token
      String? userToken =
          await _storageService.getStorageValue(LocalStorageKeys.accessToken);

      if (userToken == null) {
        debugPrint('FCM: No user token available for FCM token update');
        return false;
      }

      // API endpoint for updating FCM token
      final url = Uri.parse('${_config.apiBaseUrl}/api/user/token');

      // Prepare headers with auth token
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $userToken',
      };

      // Prepare the request body
      final body = jsonEncode({'token': token});

      // Make the PUT request with timeout
      final response = await http
          .put(
        url,
        headers: headers,
        body: body,
      )
          .timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('FCM: Update token request timed out');
          throw TimeoutException('Request timed out');
        },
      );

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          if (responseData['status'] == true) {
            debugPrint('FCM: Token successfully updated on server');
            return true;
          } else {
            debugPrint(
                'FCM: Server returned error: ${responseData['message']}');
            return false;
          }
        } catch (e) {
          debugPrint('FCM: Error parsing response: $e');
          return false;
        }
      } else {
        debugPrint(
            'FCM: Failed to update token. Status: ${response.statusCode}');
        debugPrint('FCM: Response: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('FCM: Error updating token on server: $e');
      return false;
    }
  }

  // Get the current FCM token
  Future<String?> getToken() async {
    try {
      // First try to get from storage for quick access
      String? token =
          await _storageService.getStorageValue(LocalStorageKeys.fcmToken);

      // If not in storage, get from Firebase
      if (token == null) {
        try {
          token = await _firebaseMessaging.getToken().timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              debugPrint('FCM: Token retrieval timed out');
              return null;
            },
          );

          if (token != null) {
            await _storageService.saveStorageValue(
                LocalStorageKeys.fcmToken, token);
          }
        } catch (e) {
          debugPrint('FCM: Error getting token from Firebase: $e');
          return null;
        }
      }

      return token;
    } catch (e) {
      debugPrint('FCM: Error getting token: $e');
      return null;
    }
  }
}
