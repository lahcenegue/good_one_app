abstract class AppLinks {
  static const String baseUrl = 'http://162.254.35.98';
  static const String api = '$baseUrl/api';

  // Auth endpoints
  static const String login = '$api/auth/login';
  static const String register = '$api/auth/register';

  //User endpoints
  static const String categories = '$api/categories';
  static const String contractors = '$api/services';
  static const String image = '$baseUrl/storage/images';
}
