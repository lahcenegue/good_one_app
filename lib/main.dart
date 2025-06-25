import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:good_one_app/Core/Config/app_config.dart';
import 'package:good_one_app/Core/Infrastructure/Services/notification_service.dart';
import 'package:good_one_app/Core/Presentation/Widgets/loading_indicator.dart';
import 'package:good_one_app/Core/infrastructure/Services/token_manager.dart';
import 'package:good_one_app/Providers/User/contractors_by_service_provider.dart';
import 'package:good_one_app/Providers/User/user_manager_provider.dart';
import 'package:good_one_app/Providers/Worker/orders_manager_provider.dart';
import 'package:good_one_app/Providers/Worker/worker_maganer_provider.dart';
import 'package:good_one_app/l10n/app_localizations.dart';
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

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    // Initialize core services first
    await _initializeCoreServices();

    // Initialize Firebase services
    await _initializeFirebaseServices();

    // Initialize third-party services
    await _initializeThirdPartyServices();

    debugPrint('✅ All services initialized successfully');
  } catch (e) {
    debugPrint('❌ App initialization error: $e');
    // App can still run with limited functionality
  }

  runApp(const MyApp());
}

/// Initialize core app services
Future<void> _initializeCoreServices() async {
  try {
    // Initialize StorageManager first (required by other services)
    await StorageManager.init();
    debugPrint('✅ StorageManager initialized');

    // Set global HttpOverrides for development
    HttpOverrides.global = MyHttpOverrides();
    debugPrint('✅ HTTP overrides configured');
  } catch (e) {
    debugPrint('❌ Core services initialization failed: $e');
    rethrow; // Core services are critical
  }
}

/// Initialize Firebase services
Future<void> _initializeFirebaseServices() async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized');

    // Initialize TokenManager (handles FCM tokens)
    await TokenManager.instance.initialize();
    debugPrint('✅ TokenManager initialized');

    // Initialize NotificationService
    await NotificationService.instance.initialize(
      onMessageReceived: _handleForegroundMessage,
      onMessageOpenedApp: _handleNotificationNavigation,
    );
    debugPrint('✅ NotificationService initialized');
  } catch (e) {
    debugPrint('❌ Firebase services initialization failed: $e');
    // Don't rethrow - app can work without notifications
  }
}

/// Initialize third-party services
Future<void> _initializeThirdPartyServices() async {
  try {
    // Configure Stripe
    Stripe.publishableKey = AppConfig.stripePublicKey;
    Stripe.merchantIdentifier = AppConfig.merchantIdentifier;
    Stripe.urlScheme = 'flutterstripe';
    await Stripe.instance.applySettings();
    debugPrint('✅ Stripe configured');
  } catch (e) {
    debugPrint('❌ Third-party services initialization failed: $e');
    // Don't rethrow - app can work without Stripe
  }
}

/// Handle foreground messages
void _handleForegroundMessage(RemoteMessage message) {
  debugPrint('📱 Foreground message received: ${message.notification?.title}');

  // You can add custom logic here for foreground messages
  // For example, update badges, refresh data, etc.
}

/// Handle notification navigation
void _handleNotificationNavigation(RemoteMessage message) {
  debugPrint('🧭 Navigating from notification: ${message.data}');

  // Add your navigation logic here
  final data = message.data;
  final type = data['type'];

  // Example navigation logic
  switch (type) {
    case 'chat':
      // Navigate to chat screen
      final chatId = data['chat_id'];
      debugPrint('Navigating to chat: $chatId');
      // NavigationService.navigateTo(AppRoutes.chat, arguments: chatId);
      break;

    case 'order':
      // Navigate to order screen
      final orderId = data['order_id'];
      debugPrint('Navigating to order: $orderId');
      // NavigationService.navigateTo(AppRoutes.orderDetails, arguments: orderId);
      break;

    case 'booking':
      // Navigate to booking screen
      final bookingId = data['booking_id'];
      debugPrint('Navigating to booking: $bookingId');
      // NavigationService.navigateTo(AppRoutes.bookingDetails, arguments: bookingId);
      break;

    default:
      debugPrint('Unknown notification type: $type');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core providers
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // User providers
        ChangeNotifierProvider(create: (_) => UserManagerProvider()),
        ChangeNotifierProvider(create: (_) => ContractorsByServiceProvider()),
        ChangeNotifierProvider(create: (_) => BookingManagerProvider()),

        // Worker providers
        ChangeNotifierProvider(create: (_) => WorkerManagerProvider()),
        ChangeNotifierProvider(create: (_) => OrdersManagerProvider()),

        // Chat provider
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
                body: LoadingIndicator(),
              ),
            );
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: NavigationService.navigatorKey,
            scaffoldMessengerKey: rootScaffoldMessengerKey,

            // Localization
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: appSettings.appLocale,

            // Theme and routing
            theme: AppTheme.light,
            initialRoute: appSettings.initialRoute,
            routes: AppRoutes.define(),

            // Remove splash screen when app is ready
            builder: (context, child) {
              // Remove splash screen on first build
              FlutterNativeSplash.remove();
              return child!;
            },
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
