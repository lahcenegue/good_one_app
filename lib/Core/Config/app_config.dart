class AppConfig {
  AppConfig._(); // Private constructor to prevent instantiation

  // API Configuration
  static const String appName = 'Good One App';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const Duration apiTimeout = Duration(seconds: 30);

  // Storage Configuration
  static const String storagePrefix = 'good_one_';

  // Pagination
  static const int defaultPageSize = 20;

  // Image Configuration
  static const double maxImageWidth = 1024.0;
  static const double maxImageHeight = 1024.0;
  static const int imageQuality = 85;

  // Validation Rules
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;

  // Default Settings
  static const String defaultLanguage = 'en';
}
