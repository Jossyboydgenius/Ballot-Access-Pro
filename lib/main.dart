import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ballot_access_pro/core/flavor_config.dart';
import 'package:ballot_access_pro/shared/navigation/navigation_service.dart';
import 'package:ballot_access_pro/ui/views/authentication/bloc/sign_in_bloc.dart';
import 'package:ballot_access_pro/ui/views/authentication/bloc/sign_up_bloc.dart';
import 'package:ballot_access_pro/ui/views/authentication/bloc/email_verification_bloc.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/locator.dart';
import 'shared/navigation/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'package:ballot_access_pro/shared/widgets/connection_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  await setUpLocator(AppFlavorConfig(
    name: 'Ballot Access Pro',
    apiBaseUrl: dotenv.env['BASE_URL_PROD']!,
    socketUrl: dotenv.env['SOCKET_URL_PROD']!,
    webUrl: dotenv.env['WEB_URL_PROD']!,
    sentryDsn: dotenv.env['SENTRY_DSN']!,
    mixpanelToken: dotenv.env['MIXPANEL_TOKEN_PROD']!,
  ));

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SignInBloc>(
          create: (context) => SignInBloc(),
        ),
        BlocProvider<SignUpBloc>(
          create: (context) => SignUpBloc(),
        ),
        BlocProvider<EmailVerificationBloc>(
          create: (context) => EmailVerificationBloc(),
        ),
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
  }
}
