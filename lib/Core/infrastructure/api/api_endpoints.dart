import '../../Config/app_config.dart';

abstract class ApiEndpoints {
  const ApiEndpoints._(); // Private constructor to prevent instantiation

  // Base URLs
  static final String baseUrl = AppConfig.apiBaseUrl;

  // Asset URLs
  static String get imageBaseUrl => '$baseUrl/storage/images';

  // Auth Endpoints
  static String get login => '$baseUrl/api/auth/login';
  static String get register => '$baseUrl/api/auth/register';
  static String get me => '$baseUrl/api/auth/me';
  static String get refreshToken => '$baseUrl/api/auth/refresh';

  // User Endpoints
  static String get categories => '$baseUrl/api/categories';
  static String get bestcontractors => '$baseUrl/api/services';
  static String get contractorsByService => '$baseUrl/api/services/category';
  static String get userOrders => '$baseUrl/api/user/orders';
  static String get notifications => '$baseUrl/api/user/notifications';
  static String get couponsCheck => '$baseUrl/api/coupons/check';
  static String get createOrder => '$baseUrl/api/service/order';
  static String get receiveOrder => '$baseUrl/api/service/order/complete';
  static String get cancelOrder => '$baseUrl/api/service/order/cancel';
  static String get updateOrder => '$baseUrl/api/service/order/update';
  static String get rateService => '$baseUrl/api/service/rate';

  // Stripe payment Endpoints
  static String get paymentApiUrl =>
      '${AppConfig.stripeApiBase}/payment_intents';

  //Chat Endpoints
  static String get chat => '$baseUrl/api/chat';
  static String get send => '$chat/send';
  static String messages(String userId, {int? startFrom}) {
    final base = '$chat/messages/$userId';
    return startFrom != null ? '$base?start_from=$startFrom' : base;
  }

  // Helper Methods
  static String getImageUrl(String imagePath) => '$imageBaseUrl/$imagePath';
  static String getEndpointUrl(String endpoint) => '$baseUrl/api$endpoint';
}
