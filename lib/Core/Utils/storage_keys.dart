import '../Config/app_config.dart';

abstract class StorageKeys {
  const StorageKeys._(); // Private constructor to prevent instantiation

  // Key generator
  static String _makeKey(String key) => '${AppConfig.storagePrefix}$key';

  // Settings Keys
  static final String firstLaunch = _makeKey('first_launch');
  static final String languageKey = _makeKey('language_key');
  static final String onboardingKey = _makeKey('onboarding_completed');
  static final String accountTypeKey = _makeKey('account_type');

  // Auth Keys
  static final String tokenKey = _makeKey('token');
  static final String refreshTokenKey = _makeKey('refresh_token');
  static final String fcmTokenKey = _makeKey('fcm_token');

  // User Data Keys
  static final String phoneKey = _makeKey('phone_number');
  static final String usernameKey = _makeKey('user_name');
  static final String storeNameKey = _makeKey('store_name');
  static final String profileImageKey = _makeKey('profile_image');

  // Function to generate dynamic keys
  static String makeCustomKey(String key) => _makeKey(key);
}
