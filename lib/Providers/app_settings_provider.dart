import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../Core/Constants/storage_keys.dart';
import '../../Core/Utils/navigation_service.dart';

class AppSettingsProvider extends ChangeNotifier with WidgetsBindingObserver {
  SharedPreferences? prefs;
  bool _isInitialized = false;
  late PageController pageController;
  Locale? _appLocale;
  int _pageIndex = 0;
  String? _initialRoute;

  // Getters
  bool get isInitialized => _isInitialized;
  Locale get appLocale => _appLocale ?? Locale(Intl.systemLocale);
  int get pageIndex => _pageIndex;
  String get initialRoute => _initialRoute ?? AppRoutes.languageSelection;

  AppSettingsProvider() {
    WidgetsBinding.instance.addObserver(this);
    initialize();
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      prefs = await SharedPreferences.getInstance();
      pageController = PageController(initialPage: 0);

      await _initializeLanguage();
      await _determineInitialRoute();

      _isInitialized = true;
      notifyListeners();

      // Remove splash screen after initialization
      FlutterNativeSplash.remove();
    } catch (e) {
      debugPrint('Initialization error: $e');
      _isInitialized = true;
      _initialRoute = AppRoutes.languageSelection;
      notifyListeners();
    }
  }

  Future<void> _initializeLanguage() async {
    final savedLanguage = prefs?.getString(StorageKeys.languageKey);

    if (savedLanguage != null) {
      _appLocale = Locale(savedLanguage);
    } else {
      // Use device locale or fall back to default
      final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
      final supportedLocale =
          AppLocalizations.supportedLocales.contains(deviceLocale)
              ? deviceLocale
              : const Locale('en');
      _appLocale = supportedLocale;
    }
  }

  Future<void> _determineInitialRoute() async {
    final isFirstLaunch = prefs?.getBool(StorageKeys.firstLaunch) ?? true;
    final hasLanguage = prefs?.getString(StorageKeys.languageKey) != null;
    final hasCompletedOnboarding =
        prefs?.getBool(StorageKeys.onboardingKey) ?? false;

    if (isFirstLaunch || !hasLanguage) {
      _initialRoute = AppRoutes.languageSelection;
    } else if (!hasCompletedOnboarding) {
      _initialRoute = AppRoutes.onBording;
    } else {
      _initialRoute = AppRoutes.login;
    }
  }

  Future<void> _updateAppLocale(Locale? newLocale) async {
    if (newLocale != null) {
      final matchedLocale = AppLocalizations.supportedLocales.firstWhere(
        (locale) => locale.languageCode == newLocale.languageCode,
        orElse: () => const Locale('ar'),
      );

      _appLocale = matchedLocale;
      await prefs!.setString(StorageKeys.languageKey, _appLocale!.languageCode);
      notifyListeners();
    }
  }

  Future<void> setLanguage(Locale locale) async {
    if (!AppLocalizations.supportedLocales.contains(locale)) return;

    _appLocale = locale;
    await prefs?.setString(StorageKeys.languageKey, locale.languageCode);
    await prefs?.setBool(StorageKeys.firstLaunch, false);
    notifyListeners();

    NavigationService.navigateToAndReplace(AppRoutes.onBording);
  }

  Future<void> completeOnboarding() async {
    await prefs?.setBool(StorageKeys.onboardingKey, true);
    await NavigationService.navigateToAndReplace(AppRoutes.login);
  }

  // Future<void> goToNextScreen() async {
  //   final savedLanguage = prefs!.getString(StorageKeys.languageKey);
  //   FlutterNativeSplash.remove();

  //   if (savedLanguage != null) {
  //     // Navigate to onboarding after language selection
  //     await NavigationService.navigateToAndReplace(AppRoutes.onBording);
  //   }
  // }

  void setPageIndex(int index) {
    _pageIndex = index;
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    pageController.dispose();
    super.dispose();
  }
}
