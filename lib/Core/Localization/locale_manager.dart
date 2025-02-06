import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Utils/storage_keys.dart';
import 'app_localizations.dart';

class LocaleManager {
  final SharedPreferences _prefs;

  const LocaleManager(this._prefs);

  Future<Locale> initializeLocale() async {
    final savedLanguage = _prefs.getString(StorageKeys.languageKey);
    if (savedLanguage != null) {
      return Locale(savedLanguage);
    }

    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    return AppLocalization.isSupported(deviceLocale)
        ? deviceLocale
        : const Locale('en');
  }

  Future<void> saveLocale(Locale locale) async {
    if (!AppLocalization.isSupported(locale)) return;

    await _prefs.setString(StorageKeys.languageKey, locale.languageCode);
    await _prefs.setBool(StorageKeys.firstLaunch, false);
  }

  // Getters
  bool get hasStoredLanguage =>
      _prefs.getString(StorageKeys.languageKey) != null;
  String? get currentLanguageCode => _prefs.getString(StorageKeys.languageKey);
  String get currentLanguageName =>
      AppLocalization.getLanguageName(currentLanguageCode ?? 'en');

  // Clear settings
  Future<void> clearLanguageSettings() async {
    await _prefs.remove(StorageKeys.languageKey);
    await _prefs.remove(StorageKeys.firstLaunch);
  }

  // Validation
  bool isValidLocale(Locale locale) => AppLocalization.isSupported(locale);
}
