class AppConfig {
  AppConfig._(); // Private constructor to prevent instantiation

  /// The timeout duration for API requests, set to 30 seconds.
  static const Duration apiTimeout = Duration(seconds: 30);

  /// The name of the application.
  static const String appName = 'Good One App';

  /// The version of the application,
  static const String appVersion = '1.0.0';

  /// The base URL for API endpoints.
  static const String apiBaseUrl = 'http://162.254.35.98';

  /// The base url for Stripe payment
  static const String stripeApiBase = 'https://api.stripe.com/v1';

  /// The url for secure
  static const String securLink =
      'https://secure.tritoncanada.ca/Eiv/InitiateEiv?id=7f0439e9-8dc2-8d6f-31c0-8856543a7367';

  /// The default locale for the app, set to English ('en').
  static const String defaultLocale = 'en';

  /// Default page size for pagination.
  static const int defaultPageSize = 20;

  /// Minimum length for passwords.
  static const int minPasswordLength = 4;

  /// Maximum length for passwords.
  static const int maxPasswordLength = 20;

  /// Prefix for storage keys to avoid naming conflicts.
  static const String storagePrefix = 'good_one_';
}
