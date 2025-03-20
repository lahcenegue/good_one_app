import '../Config/app_config.dart';

abstract class StorageKeys {
  const StorageKeys._(); // Private constructor to prevent instantiation

  // Key generator
  static String makeKey(String key) => '${AppConfig.storagePrefix}$key';

  // Settings Keys
  static final String firstLaunch = makeKey('first_launch');
  static final String languageKey = makeKey('language_key');
  static final String onboardingKey = makeKey('onboarding_completed');
  static final String accountTypeKey = makeKey('account_type');
  static final String vacationModeKey = makeKey('vacation_modekey');

  // Auth Keys
  static final String tokenKey = makeKey('token');
  static final String refreshTokenKey = makeKey('refresh_token');
  static final String fcmTokenKey = makeKey('fcm_token');

  // User Data Keys
  static final String phoneKey = makeKey('phone_number');
  static final String usernameKey = makeKey('user_name');
  static final String storeNameKey = makeKey('store_name');
  static final String profileImageKey = makeKey('profile_image');

  // Function to generate dynamic keys
  static String makeCustomKey(String key) => makeKey(key);
}
