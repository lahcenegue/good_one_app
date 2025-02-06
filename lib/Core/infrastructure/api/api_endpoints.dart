import '../../Config/environment.dart';

abstract class ApiEndpoints {
  const ApiEndpoints._(); // Private constructor to prevent instantiation

  // Base URLs
  static final String baseUrl = EnvironmentConfig.baseUrl;
  static final String api = EnvironmentConfig.apiUrl;

  // Auth Endpoints
  static String get login => '$api/auth/login';
  static String get register => '$api/auth/register';
  static String get userProfile => '$api/auth/me';
  static String get refreshToken => '$api/auth/refresh';

  // User Endpoints
  static String get categories => '$api/categories';
  static String get bestcontractors => '$api/services';
  static String get contractorsByService => '$api/services/category';

  // Asset URLs
  static String get imageBaseUrl => '$baseUrl/storage/images';

  // Helper Methods
  static String getImageUrl(String imagePath) => '$imageBaseUrl/$imagePath';
  static String getEndpointUrl(String endpoint) => '$api$endpoint';
}
