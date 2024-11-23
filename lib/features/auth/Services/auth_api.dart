import '../../../Core/Apis/api_service.dart';
import '../../../Core/Constants/app_links.dart';
import '../../../Data/Models/auth_model.dart';
import '../models/auth_request.dart';
import '../models/register_request.dart';

class AuthApi {
  static Future<ApiResponse<AuthModel>> login(AuthRequest request) async {
    return ApiService.post(
      url: AppLinks.login,
      body: request.toJson(),
      fromJson: (json) => AuthModel.fromJson(json),
    );
  }

  static Future<ApiResponse<AuthModel>> register(
      RegisterRequest request) async {
    return ApiService.postMultipart(
      url: AppLinks.register,
      fields: request.toFields(),
      files: request.toFiles(),
      fromJson: (json) => AuthModel.fromJson(json),
    );
  }
}
