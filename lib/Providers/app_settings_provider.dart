import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../Core/Constants/storage_keys.dart';
import '../../Core/Utils/navigation_service.dart';
import '../Features/Setup/Models/account_type.dart';
import '../Features/Setup/Models/language_option.dart';

class AppSettingsProvider extends ChangeNotifier with WidgetsBindingObserver {
  SharedPreferences? prefs;
  bool _isInitialized = false;
  late PageController pageController;
  Locale? _appLocale;
  int _pageIndex = 0;
  String? _initialRoute;
  AccountType? _selectedAccountType;
  bool _isSetupComplete = false;

  final List<LanguageOption> supportedLanguages = const [
    LanguageOption(code: 'fr', name: 'Francais', subtitle: 'Franche'),
    LanguageOption(code: 'ar', name: 'العربية', subtitle: 'Arabic'),
    LanguageOption(code: 'en', name: 'English', subtitle: 'Englais'),
    LanguageOption(code: 'af', name: 'Afrikaans', subtitle: 'Afikaans'),
    LanguageOption(code: 'sq', name: 'Shqip', subtitle: 'Albanais'),
  ];

  // Getters
  bool get isInitialized => _isInitialized;
  Locale get appLocale => _appLocale ?? Locale(Intl.systemLocale);
  int get pageIndex => _pageIndex;
  String get initialRoute => _initialRoute ?? AppRoutes.languageSelection;
  AccountType? get selectedAccountType => _selectedAccountType;
  bool get canProceed => _selectedAccountType != null;
  bool get isSetupComplete => _isSetupComplete;

  // Constructor
  AppSettingsProvider() {
    WidgetsBinding.instance.addObserver(this);
    initialize();
  }

  // Initialization methods
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      prefs = await SharedPreferences.getInstance();
      pageController = PageController(initialPage: 0);

      await _initializeLanguage();
      await _determineInitialRoute();
      await _loadSavedAccountType();

      _isInitialized = true;
      notifyListeners();

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

  Future<void> _loadSavedAccountType() async {
    final accountTypeStr = prefs?.getString(StorageKeys.accountTypeKey);
    if (accountTypeStr != null) {
      _selectedAccountType = AccountTypeExtension.fromJson(accountTypeStr);
      _isSetupComplete = true;
    }
  }

  Future<void> _determineInitialRoute() async {
    final isFirstLaunch = prefs?.getBool(StorageKeys.firstLaunch) ?? true;
    final hasLanguage = prefs?.getString(StorageKeys.languageKey) != null;
    final hasAccountType = prefs?.getString(StorageKeys.accountTypeKey) != null;
    final hasCompletedOnboarding =
        prefs?.getBool(StorageKeys.onboardingKey) ?? false;

    if (isFirstLaunch || !hasLanguage) {
      _initialRoute = AppRoutes.languageSelection;
    } else if (!hasAccountType) {
      _initialRoute = AppRoutes.accountSelection;
    } else if (!hasCompletedOnboarding) {
      _initialRoute = AppRoutes.onBording;
    } else {
      _initialRoute = AppRoutes.userMain;
    }
  }

  // Language-related methods
  Future<void> setLanguage(Locale locale) async {
    if (!AppLocalizations.supportedLocales.contains(locale)) return;

    _appLocale = locale;
    await prefs?.setString(StorageKeys.languageKey, locale.languageCode);
    await prefs?.setBool(StorageKeys.firstLaunch, false);
    notifyListeners();

    NavigationService.navigateToAndReplace(AppRoutes.accountSelection);
  }

  // Future<void> _updateAppLocale(Locale? newLocale) async {
  //   if (newLocale != null) {
  //     final matchedLocale = AppLocalizations.supportedLocales.firstWhere(
  //       (locale) => locale.languageCode == newLocale.languageCode,
  //       orElse: () => const Locale('ar'),
  //     );

  //     _appLocale = matchedLocale;
  //     await prefs!.setString(StorageKeys.languageKey, _appLocale!.languageCode);
  //     notifyListeners();
  //   }
  // }

  // Account type related methods
  bool isAccountTypeSelected(AccountType type) => _selectedAccountType == type;

  Future<void> setAccountType(AccountType type) async {
    _selectedAccountType = type;

    await prefs?.setString(StorageKeys.accountTypeKey, type.toJson());
    notifyListeners();
  }

  Future<void> proceedWithAccountType() async {
    if (_selectedAccountType != null) {
      _isSetupComplete = true;
      await NavigationService.navigateToAndReplace(AppRoutes.onBording);
    }
  }

  Future<AccountType?> getAccountType() async {
    final accountTypeStr = prefs?.getString(StorageKeys.accountTypeKey);
    return accountTypeStr != null
        ? AccountTypeExtension.fromJson(accountTypeStr)
        : null;
  }

  // Onboarding related methods
  void setPageIndex(int index) {
    _pageIndex = index;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    await prefs?.setBool(StorageKeys.onboardingKey, true);
    await NavigationService.navigateToAndReplace(AppRoutes.login);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    pageController.dispose();
    super.dispose();
  }
}
