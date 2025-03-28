import 'package:flutter/material.dart';

import 'package:good_one_app/Core/Infrastructure/Api/api_endpoints.dart';
import 'package:good_one_app/Core/Infrastructure/Api/api_response.dart';
import 'package:good_one_app/Core/Infrastructure/Api/api_service.dart';
import 'package:good_one_app/Features/Auth/Models/auth_model.dart';
import 'package:good_one_app/Features/Auth/Models/register_request.dart';
import 'package:good_one_app/Features/Auth/Models/auth_request.dart';

class AuthApi {
  static final _api = ApiService.instance;

  // Login endpoint
  static Future<ApiResponse<AuthModel>> login(AuthRequest request) async {
    return _api.post<AuthModel>(
      url: ApiEndpoints.login,
      body: request.toJson(),
      fromJson: (json) => AuthModel.fromJson(json),
    );
  }

  // Register endpoint
  static Future<ApiResponse<AuthModel>> register(
      RegisterRequest request) async {
    print(request.toFields());
    return _api.postMultipart<AuthModel>(
      url: ApiEndpoints.register,
      fields: request.toFields(),
      files: request.toFiles(),
      fromJson: (json) => AuthModel.fromJson(json),
    );
  }

  static Future<ApiResponse<AuthModel>> refreshToken({
    required String token,
  }) async {
    debugPrint('Refreshing token with current token: $token');

    return _api.post<AuthModel>(
      url: ApiEndpoints.refreshToken,
      body: {},
      fromJson: (dynamic json) {
        debugPrint('Refresh token response: $json');
        if (json is Map<String, dynamic>) {
          return AuthModel.fromJson(json);
        }
        throw Exception('Invalid refresh token response format');
      },
      token: token,
    );
  }
}
