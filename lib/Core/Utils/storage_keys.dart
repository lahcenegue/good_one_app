import 'package:good_one_app/Core/Config/app_config.dart';

abstract class StorageKeys {
  const StorageKeys._(); // Private constructor to prevent instantiation

  // Key generator
  static String makeKey(String key) => '${AppConfig.storagePrefix}$key';

  // Settings Keys
  static final String firstLaunch = makeKey('first_launch');
  static final String languageKey = makeKey('language_key');
  static final String onboardingKey = makeKey('onboarding_completed');
  static final String accountTypeKey = makeKey('account_type');
  static final String bankAccountKey = makeKey('bank_account');
  static final String interacAccountKey = makeKey('interac_account');

  // Auth Keys
  static final String tokenKey = makeKey('token');
  static final String refreshTokenKey = makeKey('refresh_token');
  static final String fcmTokenKey = makeKey('fcm_token');

  // Function to generate dynamic keys
  static String makeCustomKey(String key) => makeKey(key);
}
