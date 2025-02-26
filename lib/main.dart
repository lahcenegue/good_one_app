import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'Core/Navigation/app_routes.dart';
import 'Core/infrastructure/storage/storage_manager.dart';
import 'Core/presentation/Theme/app_theme.dart';
import 'Core/Navigation/navigation_service.dart';
import 'Features/auth/Services/token_manager.dart';
import 'Providers/app_settings_provider.dart';
import 'Providers/auth_provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'Providers/chat_provider.dart';
import 'Providers/user_state_provider.dart';
import 'Providers/worker_maganer_provider.dart';
import 'firebase_options.dart';

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
        ChangeNotifierProvider(create: (_) => UserStateProvider()),
        ChangeNotifierProvider(create: (_) => WorkerMaganerProvider()),
        ChangeNotifierProxyProvider<UserStateProvider, ChatProvider>(
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
            navigatorKey: NavigationService.navigatorKey,
            debugShowCheckedModeBanner: false,
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
