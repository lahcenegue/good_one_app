import 'app_config.dart';

enum Environment { development, staging, production }

class EnvironmentConfig {
  EnvironmentConfig._();

  static Environment currentEnvironment = Environment.development;

  // Environment checking
  static bool get isDevelopment =>
      currentEnvironment == Environment.development;
  static bool get isStaging => currentEnvironment == Environment.staging;
  static bool get isProduction => currentEnvironment == Environment.production;

  // Base URLs
  static String get baseUrl {
    switch (currentEnvironment) {
      case Environment.development:
        return 'http://162.254.35.98';
      case Environment.staging:
        return 'http://staging.goodone.com';
      case Environment.production:
        return 'https://api.goodone.com';
    }
  }

  // API URLs
  static String get apiUrl => '$baseUrl/api';
  static String get storageUrl => '$baseUrl/storage';
  static String get websocketUrl => isDevelopment
      ? 'ws://162.254.35.98'
      : isStaging
          ? 'ws://staging.goodone.com'
          : 'wss://api.goodone.com';

  // Headers
  static Map<String, String> get additionalHeaders => {
        'Accept': 'application/json',
        'X-App-Version': AppConfig.appVersion,
      };
}
