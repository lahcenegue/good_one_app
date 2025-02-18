import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../Core/Config/app_config.dart';
import '../Core/Utils/storage_keys.dart';
import '../Core/Localization/locale_manager.dart';
import '../Core/Navigation/app_routes.dart';
import '../Core/Navigation/navigation_service.dart';
import '../Core/Navigation/navigation_state.dart';
import '../Core/infrastructure/storage/storage_manager.dart';
import '../Features/Setup/Models/account_type.dart';
import '../Features/Setup/Models/language_option.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final provider = AppSettingsProvider();
  await provider.setupFlutterNotifications();
  await provider.showNotification(message);
}

class AppSettingsProvider extends ChangeNotifier with WidgetsBindingObserver {
  // Core properties
  late final LocaleManager _localeManager;
  late final PageController pageController;

  // State properties
  bool _isInitialized = false;
  Locale? _appLocale;
  int _pageIndex = 0;
  String? _initialRoute;
  AccountType? _selectedAccountType;
  bool _isSetupComplete = false;

  // Notification properties
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _isFlutterLocalNotificationsInitialized = false;
  String? _fcmToken;

  // Language options
  final List<LanguageOption> supportedLanguages = const [
    LanguageOption(code: 'fr', name: 'Francais', subtitle: 'Franche'),
    LanguageOption(code: 'ar', name: 'العربية', subtitle: 'Arabic'),
    LanguageOption(code: 'en', name: 'English', subtitle: 'Englais'),
    LanguageOption(code: 'af', name: 'Afrikaans', subtitle: 'Afikaans'),
    LanguageOption(code: 'sq', name: 'Shqip', subtitle: 'Albanais'),
  ];

  // Getters
  bool get isInitialized => _isInitialized;
  Locale get appLocale => _appLocale ?? Locale(AppConfig.defaultLanguage);
  int get pageIndex => _pageIndex;
  String get initialRoute => _initialRoute ?? AppRoutes.languageSelection;
  AccountType? get selectedAccountType => _selectedAccountType;
  bool get canProceed => _selectedAccountType != null;
  bool get isSetupComplete => _isSetupComplete;
  String? get fcmToken => _fcmToken;

  bool isAccountTypeSelected(AccountType type) => _selectedAccountType == type;

  // Constructor
  AppSettingsProvider() {
    WidgetsBinding.instance.addObserver(this);
    initialize();
  }

  // Initialization methods
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _localeManager = LocaleManager();
      pageController = PageController(initialPage: 0);

      await Future.wait([
        _initializeSettings(),
        _initializeNotifications(),
      ]);

      _isInitialized = true;
      notifyListeners();
      FlutterNativeSplash.remove();
    } catch (e) {
      debugPrint('Initialization error: $e');
      _handleInitializationError(e);
    }
  }

  void _handleInitializationError(dynamic error) {
    _isInitialized = true;
    _initialRoute = AppRoutes.languageSelection;
    notifyListeners();
  }

  // Settings initialization
  Future<void> _initializeSettings() async {
    // Set default device locale if it's first launch
    if (StorageManager.getBool(StorageKeys.firstLaunch) ?? true) {
      final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
      if (_localeManager.isValidLocale(deviceLocale)) {
        await _localeManager.saveLocale(deviceLocale);
      }
    }
    _appLocale = await _localeManager.initializeLocale();
    await _loadSavedAccountType();
    await _determineInitialRoute();
  }

  // Notification initialization and handling
  Future<void> _initializeNotifications() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await _requestNotificationPermission();
    await _setupMessageHandlers();
    await setupFlutterNotifications();

    _fcmToken = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $_fcmToken');
    await _saveFCMToken(_fcmToken);

    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      _fcmToken = newToken;
      await _saveFCMToken(newToken);
      notifyListeners();
    });
  }

  Future<void> _requestNotificationPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint(
        'Notification permission status: ${settings.authorizationStatus}');
  }

  Future<void> setupFlutterNotifications() async {
    if (_isFlutterLocalNotificationsInitialized) return;

    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = DarwinInitializationSettings();

    await _localNotifications.initialize(
      InitializationSettings(android: android, iOS: iOS),
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        debugPrint('Notification tapped: ${details.payload}');
      },
    );

    _isFlutterLocalNotificationsInitialized = true;
  }

  Future<void> showNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: message.data.toString(),
      );
    }
  }

  Future<void> _setupMessageHandlers() async {
    FirebaseMessaging.onMessage.listen(showNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    if (message.data['type'] == 'chat') {
      // Handle chat-specific navigation
    }
  }

  Future<void> _saveFCMToken(String? token) async {
    if (token != null) {
      await StorageManager.setString(StorageKeys.fcmTokenKey, token);
    }
  }

  // Language management
  Future<void> setLanguage(Locale locale) async {
    if (!_localeManager.isValidLocale(locale)) return;

    _appLocale = locale;
    await _localeManager.saveLocale(locale);
    notifyListeners();
  }

  Future<void> handleLanguageSelectionNavigation() async {
    if (!_isInitialized) await initialize();

    if (!_localeManager.hasStoredLanguage) {
      await _localeManager.saveLocale(appLocale);
    }

    final navigationState = NavigationState.fromPrefs();
    final nextRoute = navigationState.determineRoute();
    await NavigationService.navigateToAndReplace(nextRoute);
  }

  Future<void> _determineInitialRoute() async {
    final navigationState = NavigationState.fromPrefs();
    _initialRoute = navigationState.determineRoute();
  }

  // Future<bool> hasLanguageSelected() async {
  //   // Check if a language has been saved in SharedPreferences
  //   final savedLanguage = _prefs.getString(StorageKeys.languageKey);
  //   return savedLanguage != null;
  // }

  // Account type related methods
  Future<void> _loadSavedAccountType() async {
    final accountTypeStr = StorageManager.getString(StorageKeys.accountTypeKey);
    if (accountTypeStr != null) {
      _selectedAccountType = AccountTypeExtension.fromJson(accountTypeStr);
      _isSetupComplete = true;
    }
  }

  Future<void> setAccountType(AccountType type) async {
    _selectedAccountType = type;
    await StorageManager.setString(StorageKeys.accountTypeKey, type.toJson());
    notifyListeners();
  }

  Future<void> proceedWithAccountType() async {
    if (_selectedAccountType != null) {
      _isSetupComplete = true;
      await NavigationService.navigateToAndReplace(AppRoutes.onBording);
    }
  }

  // Onboarding management
  void setPageIndex(int index) {
    _pageIndex = index;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    await StorageManager.setBool(StorageKeys.onboardingKey, true);
    await NavigationService.navigateToAndReplace(AppRoutes.userMain);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    pageController.dispose();
    super.dispose();
  }
}
