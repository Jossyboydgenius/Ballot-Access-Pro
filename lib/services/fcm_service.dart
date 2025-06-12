import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/locator.dart';
import '../core/flavor_config.dart';
import '../services/local_storage_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final AppFlavorConfig _config = locator<AppFlavorConfig>();
  bool _isInitialized = false;

  // Check if Firebase is properly initialized
  bool isFirebaseInitialized() {
    try {
      // Try to access Firebase instance to check if it's initialized
      Firebase.app();
      return true;
    } catch (e) {
      debugPrint('FCM: Firebase is not initialized: $e');
      return false;
    }
  }

  // Initialize FCM service
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('FCM: Already initialized, skipping');
      return;
    }

    // First check if Firebase is properly initialized
    if (!isFirebaseInitialized()) {
      debugPrint('FCM: Firebase is not initialized, cannot initialize FCM');
      return;
    }

    try {
      debugPrint('FCM: Starting initialization...');

      // Request permission explicitly with a dialog
      await _requestNotificationPermissions();

      // Get the token
      await _getAndUpdateToken();

      // Set up message handlers
      _setupMessageHandlers();

      // Enable delivery metrics export to BigQuery
      try {
        await FirebaseMessaging.instance.setDeliveryMetricsExportToBigQuery(
          true,
        );
        debugPrint('FCM: Delivery metrics export enabled');
      } catch (e) {
        debugPrint('FCM: Error enabling delivery metrics: $e');
      }

      _isInitialized = true;
      debugPrint('FCM: Initialization completed');
    } catch (e) {
      debugPrint('FCM: Error during initialization: $e');
      // Don't rethrow to allow app to continue without FCM
    }
  }

  // Public method to force notification permission request
  Future<void> requestNotificationPermission() async {
    // For Android 13+ (API level 33+), use the permission_handler
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      debugPrint('Android notification permission status: $status');
    }

    // For iOS and additional Android configuration, use Firebase Messaging
    await _requestNotificationPermissions();
  }

  // Public method to get FCM token
  Future<String?> getToken() async {
    try {
      if (!isFirebaseInitialized()) {
        debugPrint('FCM: Firebase is not initialized, cannot get token');
        return null;
      }

      if (!_isInitialized) {
        debugPrint('FCM: Service not initialized, initializing now');
        await initialize();
      }

      String? token = await _firebaseMessaging.getToken();
      return token;
    } catch (e) {
      debugPrint('FCM: Error getting token: $e');
      return null;
    }
  }

  // Public method to check and update FCM token if user is logged in
  Future<bool> checkAndUpdateToken() async {
    try {
      // Check if user is logged in
      String? userToken = await _storageService.getStorageValue(
        LocalStorageKeys.accessToken,
      );

      if (userToken == null) {
        debugPrint('FCM: User not logged in, skipping token update');
        return false;
      }

      // Get FCM token
      String? fcmToken = await getToken();
      if (fcmToken == null) {
        debugPrint('FCM: Failed to get FCM token');
        return false;
      }

      // Update token on server
      bool result = await updateTokenOnServer(fcmToken);
      debugPrint('FCM: Token update result: $result');
      return result;
    } catch (e) {
      debugPrint('FCM: Error checking and updating token: $e');
      return false;
    }
  }

  // Request notification permissions
  Future<void> _requestNotificationPermissions() async {
    try {
      debugPrint('FCM: Requesting notification permissions...');

      // Request permission from the user
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: true,
        carPlay: true,
        criticalAlert: true,
        provisional: false,
      );

      debugPrint(
        'FCM: User notification permission status: ${settings.authorizationStatus}',
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('FCM: Notification permissions granted');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        debugPrint('FCM: Provisional notification permissions granted');
      } else {
        debugPrint('FCM: Notification permissions declined or not determined');
      }
    } catch (e) {
      debugPrint('FCM: Error requesting permissions: $e');
    }
  }

  // Get and update FCM token
  Future<void> _getAndUpdateToken() async {
    try {
      debugPrint('FCM: Getting FCM token...');
      String? token = await _firebaseMessaging.getToken();

      if (token != null && token.isNotEmpty) {
        debugPrint('FCM: Successfully retrieved token: $token');

        // Save token to storage
        await _storageService.saveStorageValue(
          LocalStorageKeys.fcmToken,
          token,
        );
        debugPrint('FCM: Token saved to local storage');

        // Update token on server if user is logged in
        String? userToken = await _storageService.getStorageValue(
          LocalStorageKeys.accessToken,
        );
        if (userToken != null) {
          final result = await updateTokenOnServer(token);
          debugPrint('FCM: Token update on server result: $result');
        } else {
          debugPrint(
            'FCM: User not logged in, token will be updated after login',
          );
        }

        // Listen for token refresh
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          debugPrint('FCM: Token refreshed: $newToken');

          // Save the new token
          _storageService
              .saveStorageValue(LocalStorageKeys.fcmToken, newToken)
              .then((_) => debugPrint('FCM: Refreshed token saved to storage'))
              .catchError(
                (e) => debugPrint('FCM: Error saving refreshed token: $e'),
              );

          // Update on server if user is logged in
          _storageService.getStorageValue(LocalStorageKeys.accessToken).then((
            userToken,
          ) {
            if (userToken != null) {
              updateTokenOnServer(newToken)
                  .then(
                    (result) => debugPrint(
                      'FCM: Refreshed token update result: $result',
                    ),
                  )
                  .catchError(
                    (e) =>
                        debugPrint('FCM: Error updating refreshed token: $e'),
                  );
            }
          });
        });
      } else {
        debugPrint('FCM: Failed to get FCM token');
      }
    } catch (e) {
      debugPrint('FCM: Error getting or updating token: $e');
    }
  }

  // Set up message handlers
  void _setupMessageHandlers() {
    try {
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('FCM: Received foreground message:');
        debugPrint('FCM: Title: ${message.notification?.title}');
        debugPrint('FCM: Body: ${message.notification?.body}');
        debugPrint('FCM: Data: ${message.data}');
      });

      // Handle background message opening
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('FCM: User opened app from notification:');
        debugPrint('FCM: Title: ${message.notification?.title}');
        debugPrint('FCM: Body: ${message.notification?.body}');
        debugPrint('FCM: Data: ${message.data}');
      });

      // Check for initial message (app opened from terminated state)
      FirebaseMessaging.instance.getInitialMessage().then((
        RemoteMessage? message,
      ) {
        if (message != null) {
          debugPrint('FCM: App opened from terminated state via notification:');
          debugPrint('FCM: Title: ${message.notification?.title}');
          debugPrint('FCM: Body: ${message.notification?.body}');
          debugPrint('FCM: Data: ${message.data}');
        }
      });

      debugPrint('FCM: Message handlers set up successfully');
    } catch (e) {
      debugPrint('FCM: Error setting up message handlers: $e');
    }
  }

  // Update FCM token on server
  Future<bool> updateTokenOnServer(String token) async {
    try {
      // Get the current user token
      String? userToken = await _storageService.getStorageValue(
        LocalStorageKeys.accessToken,
      );

      if (userToken == null) {
        debugPrint('FCM: No user token available for FCM token update');
        return false;
      }

      // API endpoint
      final url = Uri.parse('${_config.apiBaseUrl}/api/user/token');
      debugPrint('FCM: Updating token at endpoint: $url');

      // Prepare headers with auth token
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $userToken',
      };

      // Prepare the request body
      final body = jsonEncode({'token': token});
      debugPrint('FCM: Sending token update request');

      // Make the PUT request
      final response =
          await http.put(url, headers: headers, body: body).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('FCM: Token update request timed out');
          throw TimeoutException('Request timed out');
        },
      );

      debugPrint('FCM: Token update response status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final responseData = jsonDecode(response.body);
          if (responseData['status'] == true) {
            debugPrint('FCM: Token successfully updated on server');
            return true;
          } else {
            debugPrint(
              'FCM: Server returned error: ${responseData['message']}',
            );
            return false;
          }
        } catch (e) {
          debugPrint('FCM: Error parsing response: $e');
          return false;
        }
      } else {
        debugPrint(
          'FCM: Failed to update token. Status: ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('FCM: Error updating token on server: $e');
      return false;
    }
  }
}
