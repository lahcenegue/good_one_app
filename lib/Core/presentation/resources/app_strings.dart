abstract class AppStrings {
  const AppStrings._(); // Private constructor to prevent instantiation

  // Account Types
  static const String user = 'Customer';
  static const String service = 'worker';

  // General
  static const String appName = 'Good One';
  static const String version = '1.0.0';

  // Stripe Info
  static String stripeSecretKey =
      'sk_test_51PwTFRRxXcdOUoWKBzN8Mf5YNuPtGEJUfcsDZ5NbcMN5TDFUzWMQnaFIZU0zwl5r5ynK9RjBYaoktRov2a1jPhtm00u8lCvbVv';
  static String stripePublicKey =
      'pk_test_51PwTFRRxXcdOUoWK9C7Owj6MF2u9DjQInIm5peKUTsL3pc6ENUJlfFrUZvB9hENfLI2CcQyYy6XRHg7xwjFt6Ttc00zhWQgBth';
  static String stripeAccountId = 'acct_1PwTFRRxXcdOUoWK';
  static String merchantIdentifier = 'merchant.com.example.good_one_app';

  // Error Messages
  static const String serverError = 'Server error. Please try again later.';
  static const String generalError = 'Something went wrong. Please try again.';
  static const String networkError = 'Please check your internet connection.';
  static const String timeoutError = 'Request timeout. Please try again.';
  static const String authError = 'Authentication failed. Please login again.';
  static const String sessionExpired = 'The session is Expired';

  // Success Messages
  static const String saved = 'Successfully saved';
  static const String updated = 'Successfully updated';
  static const String deleted = 'Successfully deleted';

  // Button Texts
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String save = 'Save';

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
