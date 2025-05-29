import 'package:flutter/material.dart';

import 'package:good_one_app/Core/Infrastructure/Api/api_endpoints.dart';
import 'package:good_one_app/Core/Infrastructure/Api/api_response.dart';
import 'package:good_one_app/Core/Infrastructure/Api/api_service.dart';
import 'package:good_one_app/Features/Auth/Models/auth_model.dart';
import 'package:good_one_app/Features/Auth/Models/check_request.dart';
import 'package:good_one_app/Features/Auth/Models/opt_message_model.dart';
import 'package:good_one_app/Features/Auth/Models/register_request.dart';
import 'package:good_one_app/Features/Auth/Models/auth_request.dart';
import 'package:good_one_app/Features/Auth/Models/reset_password_request.dart';

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

  static Future<ApiResponse<OtpMessageModel>> sendOtp(
      {required String email}) async {
    return _api.post(
      url: ApiEndpoints.sendOtp,
      body: {'email': email},
      fromJson: (json) => OtpMessageModel.fromJson(json),
    );
  }

  static Future<ApiResponse<AuthModel>> checkOtp(CheckRequest request) async {
    return _api.post<AuthModel>(
      url: ApiEndpoints.checkOtp,
      body: request.toJson(),
      fromJson: (json) => AuthModel.fromJson(json),
    );
  }

  static Future<ApiResponse<OtpMessageModel>> resetPassword(
      ResetPasswordRequest request) async {
    return _api.post(
      url: ApiEndpoints.resetPassword,
      body: request.toJson(),
      fromJson: (json) => OtpMessageModel.fromJson(json),
    );
  }
}
