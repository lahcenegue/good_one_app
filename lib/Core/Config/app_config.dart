class AppConfig {
  AppConfig._(); // Private constructor to prevent instantiation

  /// The timeout duration for API requests, set to 30 seconds.
  static const Duration apiTimeout = Duration(seconds: 30);

  /// The name of the application.
  static const String appName = 'Good One';

  /// The version of the application,
  static const String appVersion = '1.0.0';

  /// The base URL for API endpoints.
  static const String apiBaseUrl = 'http://162.254.35.98';

  /// The base url for Stripe payment
  static const String stripeApiBase = 'https://api.stripe.com/v1';

  /// Support Email
  static const String supportEmail = 'haveagoodoneapp@gmail.com';

  /// The url for secure
  static const String securLink =
      'https://secure.tritoncanada.ca/Eiv/InitiateEiv?id=7f0439e9-8dc2-8d6f-31c0-8856543a7367';

  /// WhatsApp number
  static const String whatsAppNumber = '+1(306)3511781';

  /// The default locale for the app, set to English ('en').
  static const String defaultLocale = 'en';

  /// Default page size for pagination.
  static const int defaultPageSize = 20;

  /// Minimum length for passwords.
  static const int minPasswordLength = 4;

  /// Prefix for storage keys to avoid naming conflicts.
  static const String storagePrefix = 'good_one_';

  /// Account Types
  static const String user = 'Customer';
  static const String service = 'worker';

  /// Stripe Info
  static String stripeSecretKey =
      'sk_test_51PwTFRRxXcdOUoWKBzN8Mf5YNuPtGEJUfcsDZ5NbcMN5TDFUzWMQnaFIZU0zwl5r5ynK9RjBYaoktRov2a1jPhtm00u8lCvbVv';
  static String stripePublicKey =
      'pk_test_51PwTFRRxXcdOUoWK9C7Owj6MF2u9DjQInIm5peKUTsL3pc6ENUJlfFrUZvB9hENfLI2CcQyYy6XRHg7xwjFt6Ttc00zhWQgBth';
  static String stripeAccountId = 'acct_1PwTFRRxXcdOUoWK';
  static String merchantIdentifier = 'merchant.com.example.good_one_app';

  static List<String> countries = [
    'Canada',
    'United States',
  ];

  static Map<String, List<String>> citiesByCountry = {
    'United States': [
      'New York',
      'Los Angeles',
      'Chicago',
      'Houston',
      'Phoenix',
    ],
    'Canada': [
      'Toronto',
      'Vancouver',
      'Montreal',
      'Calgary',
      'Ottawa',
    ],
  };

  static const List<String> validRegions = [
    'Alberta',
    'British Columbia',
    'Manitoba',
    'New Brunswick',
    'Newfoundland and Labrador',
    'Northwest Territories',
    'Nova Scotia',
    'Nunavut',
    'Ontario',
    'Prince Edward Island',
    'Québec',
    'Saskatchewan',
    'Yukon',
  ];

  static List<int> availableDurations = [1, 2, 3, 4, 5, 6, 7, 8];
  static const List<String> timeSlots = [
    '00:00',
    '01:00',
    '02:00',
    '03:00',
    '04:00',
    '05:00',
    '06:00',
    '07:00',
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
    '21:00',
    '22:00',
    '23:00',
  ];
}
