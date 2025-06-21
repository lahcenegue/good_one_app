import 'package:good_one_app/Core/Config/app_config.dart';

abstract class ApiEndpoints {
  const ApiEndpoints._(); // Private constructor to prevent instantiation

  // Base URLs
  static final String baseUrl = AppConfig.apiBaseUrl;

  // Asset URLs
  static String get imageBaseUrl => '$baseUrl/storage/images';

  // Auth Endpoints
  static String get login => '$baseUrl/api/auth/login';
  static String get register => '$baseUrl/api/auth/register';
  static String get refreshToken => '$baseUrl/api/auth/refresh';
  static String get sendOtp => '$baseUrl/api/auth/password/reset/code';
  static String get checkOtp => '$baseUrl/api/auth/verifyAccount';
  static String get resetPassword => '$baseUrl/api/auth/password/reset';

  // Both Endpoints
  static String get me => '$baseUrl/api/auth/me';
  static String get taxes => '$baseUrl/api/taxes';

  // Notifications Endpoints
  static String get notifications => '$baseUrl/api/user/notifications';
  static String get newNotificationsCount =>
      '$baseUrl/api/user/notifications/count/new';
  static String get unreadNotificationsCount =>
      '$baseUrl/api/user/notifications/count/unread';
  static String get markNotificationsAsSeen =>
      '$baseUrl/api/user/notifications/mark-seen';
  static String get markNotificationsAsRead =>
      '$baseUrl/api/user/notifications/mark-read';
  static String get markAllNotificationsAsRead =>
      '$baseUrl/api/user/notifications/mark-all-read';

  // User Endpoints
  static String get search => '$baseUrl/api/services?query';
  static String get categories => '$baseUrl/api/categories';
  static String get bestcontractors => '$baseUrl/api/services';
  static String get contractorsByService => '$baseUrl/api/services/category';
  static String get userOrders => '$baseUrl/api/user/orders';
  static String get couponsCheck => '$baseUrl/api/coupons/check';
  static String get createOrder => '$baseUrl/api/service/order';
  static String get receiveOrder => '$baseUrl/api/service/order/complete';
  static String get cancelOrder => '$baseUrl/api/service/order/cancel';
  static String get updateOrder => '$baseUrl/api/service/order/update';
  static String get rateService => '$baseUrl/api/service/rate';
  static String get accountEdit => '$baseUrl/api/account/edit';

  //Worker Endpoints
  static String get addImage => '$baseUrl/api/account/gallary/add';
  static String get removeImage => '$baseUrl/api/account/gallary/remove';
  static String get createNewService => '$baseUrl/api/service/create';
  static String get editNewService => '$baseUrl/api/service/edit';
  static String get getMyService => '$baseUrl/api/user/services';
  static String get serviceOrders => '$baseUrl/api/service/orders';
  static String get changeAccountState => '$baseUrl/api/account/change_state';
  static String get balance => '$baseUrl/api/user/balance';
  static String get withdrawReauest => '$baseUrl/api/user/balance/withdraw';
  static String get withdrawStatus =>
      '$baseUrl/api/user/balance/withdraw/requests';
  static String get earningsHistory => '$baseUrl/api/user/earnings/history';
  static String get earningsSummary => '$baseUrl/api/user/earnings/summary';

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
