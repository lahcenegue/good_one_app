import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:good_one_app/Core/Config/app_config.dart';
import 'package:good_one_app/Core/Infrastructure/Storage/storage_manager.dart';
import 'package:good_one_app/Core/Localization/locale_manager.dart';
import 'package:good_one_app/Core/Infrastructure/Services/notification_service.dart';
import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Navigation/navigation_service.dart';
import 'package:good_one_app/Core/Navigation/navigation_state.dart';
import 'package:good_one_app/Core/Utils/storage_keys.dart';
import 'package:good_one_app/Features/Setup/Models/account_type.dart';

class AppSettingsProvider extends ChangeNotifier with WidgetsBindingObserver {
  final LocaleManager _localeManager;
  final NotificationService _notificationService;
  late final PageController pageController;

  bool _isInitialized = false;
  Locale? _appLocale;
  int _pageIndex = 0;
  String? _initialRoute;
  AccountType? _selectedAccountType;
  bool _isSetupComplete = false;

  // Getters
  bool get isInitialized => _isInitialized;
  Locale get appLocale => _appLocale ?? Locale(AppConfig.defaultLocale);
  int get pageIndex => _pageIndex;
  String get initialRoute => _initialRoute ?? AppRoutes.languageSelection;
  AccountType? get selectedAccountType => _selectedAccountType;
  bool get canProceed => _selectedAccountType != null;
  bool get isSetupComplete => _isSetupComplete;
  String? get fcmToken => _notificationService.fcmToken;

  bool isAccountTypeSelected(AccountType type) => _selectedAccountType == type;

  // Constructor with dependency injection
  AppSettingsProvider({
    LocaleManager? localeManager,
    NotificationService? notificationService,
  })  : _localeManager = localeManager ?? LocaleManager(),
        _notificationService = notificationService ?? NotificationService() {
    WidgetsBinding.instance.addObserver(this);
    initialize();
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await StorageManager.init(); // Explicitly initialize StorageManager
      pageController = PageController(initialPage: 0);

      await Future.wait([
        _initializeSettings(),
        _notificationService.initialize(),
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

  Future<void> _initializeSettings() async {
    final isFirstLaunch =
        await StorageManager.getBool(StorageKeys.firstLaunch) ?? true;
    if (isFirstLaunch) {
      final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
      if (_localeManager.isValidLocale(deviceLocale)) {
        await _localeManager.saveLocale(deviceLocale);
      }
    }
    _appLocale = await _localeManager.initializeLocale();
    await _loadSavedAccountType();
    await _determineInitialRoute();
  }

  // Language management
  Future<void> setLanguage(Locale locale) async {
    try {
      if (!_localeManager.isValidLocale(locale)) return;
      _appLocale = locale;
      await _localeManager.saveLocale(locale);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to set language: $e');
    }
  }

  Future<void> handleLanguageSelectionNavigation() async {
    try {
      if (!_isInitialized) await initialize();
      final hasStoredLanguage = await _localeManager.hasStoredLanguage;
      if (!hasStoredLanguage) {
        await _localeManager.saveLocale(appLocale);
      }
      final navigationState = await NavigationState.fromPrefs();
      final nextRoute = navigationState.determineRoute();
      await NavigationService.navigateToAndReplace(nextRoute);
    } catch (e) {
      debugPrint('Language selection navigation failed: $e');
      await NavigationService.navigateToAndReplace(AppRoutes.languageSelection);
    }
  }

  Future<void> _determineInitialRoute() async {
    final navigationState = await NavigationState.fromPrefs();
    _initialRoute = navigationState.determineRoute();
  }

  // Account type management
  Future<void> _loadSavedAccountType() async {
    final accountTypeStr =
        await StorageManager.getString(StorageKeys.accountTypeKey);
    if (accountTypeStr != null) {
      _selectedAccountType = AccountTypeExtension.fromJson(accountTypeStr);
      _isSetupComplete = true;
    }
  }

  Future<void> setAccountType(AccountType type) async {
    try {
      _selectedAccountType = type;
      await StorageManager.setString(StorageKeys.accountTypeKey, type.toJson());
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to set account type: $e');
    }
  }

  Future<void> proceedWithAccountType() async {
    if (_selectedAccountType == null) return;
    _isSetupComplete = true;
    await _navigateToNextRoute(AppRoutes.onBording);
  }

  // Onboarding management
  void setPageIndex(int index) {
    _pageIndex = index;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    try {
      await StorageManager.setBool(StorageKeys.onboardingKey, true);
      final [token, accountType] = await Future.wait([
        StorageManager.getString(StorageKeys.tokenKey),
        StorageManager.getString(StorageKeys.accountTypeKey),
      ]);

      String nextRoute;
      if (token == null) {
        nextRoute = AppRoutes.userMain;
      } else {
        nextRoute = accountType == AppConfig.service
            ? AppRoutes.workerMain
            : AppRoutes.userMain;
      }
      await _navigateToNextRoute(nextRoute);
    } catch (e) {
      debugPrint('Failed to complete onboarding: $e');
      await _navigateToNextRoute(AppRoutes.userMain); // Fallback
    }
  }

  // Helper method to DRY navigation logic
  Future<void> _navigateToNextRoute(String route) async {
    await NavigationService.navigateToAndReplace(route);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    pageController.dispose();
    super.dispose();
  }
}
