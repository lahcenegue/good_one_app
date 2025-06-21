import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:good_one_app/Core/Config/app_config.dart';
import 'package:good_one_app/Providers/User/contractors_by_service_provider.dart';
import 'package:good_one_app/Providers/User/user_manager_provider.dart';
import 'package:good_one_app/Providers/Worker/orders_manager_provider.dart';
import 'package:good_one_app/Providers/Worker/worker_maganer_provider.dart';
import 'package:provider/provider.dart';

import 'package:good_one_app/Providers/Both/app_settings_provider.dart';
import 'package:good_one_app/Providers/Both/auth_provider.dart';
import 'package:good_one_app/Providers/Both/chat_provider.dart';
import 'package:good_one_app/Providers/User/booking_manager_provider.dart';

import 'package:good_one_app/Core/Infrastructure/Storage/storage_manager.dart';
import 'package:good_one_app/firebase_options.dart';
import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Navigation/navigation_service.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_theme.dart';
import 'package:good_one_app/Features/Auth/Services/token_manager.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize StorageManager
  await StorageManager.init();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize TokenManager
  await TokenManager.instance.initialize();

  // Set Stripe publishable key from AppStrings
  Stripe.publishableKey = AppConfig.stripePublicKey;
  Stripe.merchantIdentifier = AppConfig.merchantIdentifier;
  Stripe.urlScheme = 'flutterstripe';
  await Stripe.instance.applySettings();

  // Set global HttpOverrides
  HttpOverrides.global = MyHttpOverrides();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserManagerProvider()),
        ChangeNotifierProvider(create: (_) => ContractorsByServiceProvider()),
        ChangeNotifierProvider(create: (_) => BookingManagerProvider()),
        ChangeNotifierProvider(create: (_) => WorkerManagerProvider()),
        ChangeNotifierProvider(create: (_) => OrdersManagerProvider()),
        ChangeNotifierProxyProvider<UserManagerProvider, ChatProvider>(
          create: (context) => ChatProvider(),
          update: (context, userManager, previous) {
            final chatProvider = previous ?? ChatProvider();
            return chatProvider;
          },
        ),
      ],
      child: Consumer<AppSettingsProvider>(
        builder: (context, appSettings, _) {
          if (!appSettings.isInitialized) {
            return MaterialApp(
              theme: AppTheme.light,
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: NavigationService.navigatorKey,
            scaffoldMessengerKey: rootScaffoldMessengerKey,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: appSettings.appLocale,
            theme: AppTheme.light,
            initialRoute: appSettings.initialRoute,
            routes: AppRoutes.define(),
          );
        },
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
