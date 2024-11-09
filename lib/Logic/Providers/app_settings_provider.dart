import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../Core/Constants/storage_keys.dart';
import '../../Core/Utils/navigation_service.dart';

class AppSettingsProvider extends ChangeNotifier with WidgetsBindingObserver {
  SharedPreferences? _prefs;

  AppSettingsProvider() {
    WidgetsBinding.instance.addObserver(this);
    initialize();
  }

  // State
  bool _isInitialized = false;
  late PageController pageController;
  Locale? _appLocale;
  int _pageIndex = 0;

  // Getters
  bool get isInitialized => _isInitialized;
  Locale get appLocale => _appLocale ?? Locale(Intl.systemLocale);
  int get pageIndex => _pageIndex;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    pageController = PageController(initialPage: 0);
    await _initializeLanguage();
    await goToNextScreen();

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _initializeLanguage() async {
    final savedLanguage = _prefs!.getString(StorageKeys.languageKey);

    if (savedLanguage == null) {
      final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
      _updateAppLocale(deviceLocale);
    } else {
      _appLocale = Locale(savedLanguage);
    }
  }

  void _updateAppLocale(Locale? newLocale) {
    if (newLocale != null) {
      final matchedLocale = AppLocalizations.supportedLocales.firstWhere(
        (locale) => locale.languageCode == newLocale.languageCode,
        orElse: () => const Locale('ar'),
      );

      _appLocale = matchedLocale;
      _prefs!.setString(StorageKeys.languageKey, _appLocale!.languageCode);
      notifyListeners();
    }
  }

  Future<void> changeLanguage(Locale newLocale) async {
    if (!AppLocalizations.supportedLocales.contains(newLocale)) return;
    if (newLocale != _appLocale) {
      _appLocale = newLocale;

      await _prefs!.setString(StorageKeys.languageKey, newLocale.languageCode);
      notifyListeners();
    }
  }

  Future<void> goToNextScreen() async {
    Future.delayed(
      const Duration(seconds: 2),
      () async {
        await NavigationService.navigateToAndReplace(
            AppRoutes.languageSelection);
      },
    );
  }

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
