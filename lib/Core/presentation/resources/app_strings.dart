abstract class AppStrings {
  const AppStrings._(); // Private constructor to prevent instantiation

  // Account Types
  static const String user = 'Customer';
  static const String service = 'Profissionel';

  // General
  static const String appName = 'Good One';
  static const String version = '1.0.0';

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
}
