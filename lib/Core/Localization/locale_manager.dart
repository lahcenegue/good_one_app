import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Infrastructure/Storage/storage_manager.dart';
import 'package:good_one_app/Core/Localization/app_localizations.dart';
import 'package:good_one_app/Core/Utils/storage_keys.dart';

class LocaleManager {
  const LocaleManager();

  Future<Locale> initializeLocale() async {
    final savedLanguage =
        await StorageManager.getString(StorageKeys.languageKey);
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

    await StorageManager.setString(
        StorageKeys.languageKey, locale.languageCode);
    await StorageManager.setBool(StorageKeys.firstLaunch, false);
  }

  // Getters
  Future<bool> get hasStoredLanguage async {
    final language = await StorageManager.getString(StorageKeys.languageKey);
    return language != null;
  }

  Future<String?> get currentLanguageCode async {
    return await StorageManager.getString(StorageKeys.languageKey);
  }

  Future<String> get currentLanguageName async {
    final code = await StorageManager.getString(StorageKeys.languageKey);
    return AppLocalization.getLanguageName(code ?? 'en');
  }

  // Clear settings
  Future<void> clearLanguageSettings() async {
    await StorageManager.remove(StorageKeys.languageKey);
    await StorageManager.remove(StorageKeys.firstLaunch);
  }

  // Validation
  bool isValidLocale(Locale locale) => AppLocalization.isSupported(locale);
}
