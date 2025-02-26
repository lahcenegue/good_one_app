abstract class ApiEndpoints {
  const ApiEndpoints._(); // Private constructor to prevent instantiation

  // Base URLs
  static final String baseUrl = 'http://162.254.35.98';

  // Asset URLs
  static String get imageBaseUrl => '$baseUrl/storage/images';

  // Auth Endpoints
  static String get login => '$baseUrl/api/auth/login';
  static String get register => '$baseUrl/api/auth/register';
  static String get userProfile => '$baseUrl/api/auth/me';
  static String get refreshToken => '$baseUrl/api/auth/refresh';

  // User Endpoints
  static String get categories => '$baseUrl/api/categories';
  static String get bestcontractors => '$baseUrl/api/services';
  static String get contractorsByService => '$baseUrl/api/services/category';
  static String get bookings => '$baseUrl/api/user/orders';

  // Helper Methods
  static String getImageUrl(String imagePath) => '$imageBaseUrl/$imagePath';
  static String getEndpointUrl(String endpoint) => '$baseUrl/api$endpoint';
}
