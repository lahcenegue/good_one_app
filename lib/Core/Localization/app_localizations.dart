import 'package:flutter/material.dart';

import 'package:good_one_app/Features/Setup/Models/language_option.dart';

import 'package:good_one_app/l10n/app_localizations.dart';

class AppLocalization {
  const AppLocalization._();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('fr'),
    Locale('ar'),
    Locale('af'),
    Locale('sq'),
  ];

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    AppLocalizations.delegate,
    // Add other delegates if needed
  ];

  static bool isSupported(Locale locale) {
    return supportedLocales.contains(locale);
  }

  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      case 'ar':
        return 'العربية';
      case 'af':
        return 'Afrikaans';
      case 'sq':
        return 'Shqip';
      default:
        return 'Unknown';
    }
  }

  static List<LanguageOption> supportedLanguages = const [
    LanguageOption(code: 'fr', name: 'Francais', subtitle: 'Franche'),
    LanguageOption(code: 'ar', name: 'العربية', subtitle: 'Arabic'),
    LanguageOption(code: 'en', name: 'English', subtitle: 'Englais'),
    LanguageOption(code: 'af', name: 'Afrikaans', subtitle: 'Afikaans'),
    LanguageOption(code: 'sq', name: 'Shqip', subtitle: 'Albanais'),
  ];
}
