import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ballot_access_pro/core/flavor_config.dart';
import 'package:ballot_access_pro/shared/navigation/navigation_service.dart';
import 'package:ballot_access_pro/shared/utils/debug_utils.dart';
import 'package:ballot_access_pro/ui/views/authentication/bloc/sign_in_bloc.dart';
import 'package:ballot_access_pro/ui/views/authentication/bloc/sign_up_bloc.dart';
import 'package:ballot_access_pro/ui/views/authentication/bloc/email_verification_bloc.dart';
import 'package:ballot_access_pro/ui/views/petitioner/bloc/work_bloc.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/locator.dart';
import 'shared/navigation/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'package:ballot_access_pro/shared/widgets/connection_widget.dart';
import 'package:ballot_access_pro/services/fcm_service.dart';

// Define a top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  try {
    await Firebase.initializeApp();
    debugPrint("Handling a background message: ${message.messageId}");
    debugPrint("Message data: ${message.data}");
    debugPrint("Message notification: ${message.notification?.title}");
    debugPrint("Message notification: ${message.notification?.body}");
  } catch (e) {
    debugPrint("Error in background message handler: $e");
  }
}

// Global variable to track Firebase initialization
bool isFirebaseInitialized = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set up app configuration first
    await setUpLocator(
      AppFlavorConfig(
        name: 'Ballot Access Pro',
        apiBaseUrl: dotenv.env['BASE_URL_PROD']!,
        socketUrl: dotenv.env['SOCKET_URL_PROD']!,
        webUrl: dotenv.env['WEB_URL_PROD']!,
        sentryDsn: dotenv.env['SENTRY_DSN']!,
        mixpanelToken: dotenv.env['MIXPANEL_TOKEN_PROD']!,
      ),
    );

    // Log debug mode status
    debugPrint(
        '🔧 App running in ${DebugUtils.isDebugMode ? 'DEBUG' : 'RELEASE'} mode');

    // Initialize Firebase with the correct options from google-services.json
    try {
      // Define Firebase options based on the google-services.json file
      const FirebaseOptions firebaseOptions = FirebaseOptions(
        apiKey: 'AIzaSyBUCPniH8iVLXSC4oLXKImSYnBe3dr0zHg',
        appId: '1:275057923056:android:7e3d42d9ba946b33594335',
        messagingSenderId: '275057923056',
        projectId: 'nnu-income-programme',
        storageBucket: 'nnu-income-programme.appspot.com',
      );

      await Firebase.initializeApp(options: firebaseOptions);
      isFirebaseInitialized = true;
      debugPrint('Firebase initialized successfully with provided config');

      // Set up background messaging handler
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
    } catch (e) {
      debugPrint('Firebase initialization error: $e');
      debugPrint('Continuing without Firebase services');
    }

    runApp(const MainApp());
  } catch (e) {
    debugPrint('Startup error: $e');
    // Run a minimal app if initialization fails
    runApp(
      MaterialApp(
        home: Scaffold(body: Center(child: Text('Error initializing app: $e'))),
      ),
    );
  }
}

// Request all permissions needed by the app
Future<void> requestAppPermissions() async {
  // Request notification permission for Android 13+
  if (isFirebaseInitialized) {
    // First check if notification permission is already granted
    final status = await Permission.notification.status;
    debugPrint('Current notification permission status: $status');

    if (status.isDenied) {
      // Show a dialog explaining why we need notification permissions
      // This should be called from a UI context where the user can see it
      debugPrint('Requesting notification permission with dialog');
      final result = await Permission.notification.request();
      debugPrint('Notification permission request result: $result');
    }

    // Use FCM to request notification permissions (especially important for iOS)
    final fcmService = locator<FCMService>();
    await fcmService.initialize();
  }
}

// Separate method to initialize FCM
Future<void> initializeFCM() async {
  if (!isFirebaseInitialized) {
    debugPrint('Firebase not initialized, skipping FCM initialization');
    return;
  }

  try {
    // Initialize FCM service
    final fcmService = locator<FCMService>();
    await fcmService.initialize();
    debugPrint('FCM service initialized successfully');
  } catch (e) {
    debugPrint('FCM initialization error: $e');
    // Continue without FCM
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Request permissions first before initializing FCM
    if (isFirebaseInitialized) {
      // Request notification permission explicitly
      await requestAppPermissions();

      // Now initialize FCM after permissions are handled
      await initializeFCM();

      // Check and update FCM token if user is logged in
      final fcmService = locator<FCMService>();
      await fcmService.checkAndUpdateToken();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializationFuture,
      builder: (context, snapshot) {
        // Return loading indicator while initializing
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        // If there's an error, show a basic error screen but continue with the app
        if (snapshot.hasError) {
          debugPrint('Error initializing FCM: ${snapshot.error}');
          // We'll continue with the app anyway
        }

        // App is fully initialized, return the main app
        return MultiBlocProvider(
          providers: [
            BlocProvider<SignInBloc>(create: (context) => SignInBloc()),
            BlocProvider<SignUpBloc>(create: (context) => SignUpBloc()),
            BlocProvider<EmailVerificationBloc>(
              create: (context) => EmailVerificationBloc(),
            ),
            BlocProvider<WorkBloc>(create: (context) => WorkBloc()),
            // Add other blocs here as needed
          ],
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp(
                title: 'Ballot Access Pro',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                navigatorKey: NavigationService.navigatorKey,
                initialRoute: AppRoutes.initialRoute,
                routes: AppRoutes.routes,
                builder: (context, child) {
                  return ConnectionWidget(
                    dismissOfflineBanner: false,
                    builder: (BuildContext context, bool isOnline) {
                      return BotToastInit()(context, child);
                    },
                  );
                },
                navigatorObservers: [BotToastNavigatorObserver()],
              );
            },
          ),
        );
      },
    );
  }
}
