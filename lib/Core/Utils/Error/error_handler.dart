import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../Features/auth/Services/token_manager.dart';
import '../../Navigation/app_routes.dart';
import '../../Navigation/navigation_service.dart';
import '../../presentation/resources/app_strings.dart';

import 'failures.dart';

class ErrorHandler {
  const ErrorHandler._();

  // Handle general exceptions
  static Failure handleException(dynamic error) {
    if (error is Failure) return error;

    if (error is SocketException || error is TimeoutException) {
      return const NetworkFailure(
        message: AppStrings.networkError,
        code: 'network_error',
      );
    }

    if (error is FormatException) {
      return const NetworkFailure(
        message: 'Invalid response format from server.',
        code: 'format_error',
      );
    }

    return NetworkFailure(
      message: error?.toString() ?? AppStrings.generalError,
      code: 'unknown_error',
    );
  }

  // Check if token is expired from response
  static bool isTokenExpired(dynamic response) {
    if (response is Map<String, dynamic>) {
      final message = response['message']?.toString().toLowerCase() ?? '';
      return message.contains('unauthenticated') ||
          message.contains('expired') ||
          message.contains('invalid token') ||
          message.contains('token has expired');
    }
    return false;
  }

  // Handle API specific errors
  static Failure handleApiError(dynamic response, {BuildContext? context}) {
    if (response is Map<String, dynamic>) {
      final statusCode = response['statusCode'] as int?;
      final message = response['message'] as String?;
      final errors = response['errors'] as Map<String, dynamic>?;

      // Check for token expiration first
      if (isTokenExpired(response)) {
        // Handle session expiration
        _handleSessionExpiration(context);

        return const AuthFailure(
          message: AppStrings.sessionExpired,
          code: 'session_expired',
        );
      }

      // Handle other status codes
      return _getFailureForStatusCode(
        statusCode: statusCode,
        message: message,
        errors: errors,
      );
    }

    return const NetworkFailure(
      message: AppStrings.generalError,
      code: 'unknown_error',
    );
  }

  // Handle session expiration
  static Future<void> _handleSessionExpiration(BuildContext? context) async {
    debugPrint('Handling session expiration');

    try {
      // Try to refresh token first
      final refreshed = await TokenManager.instance.refreshToken();

      if (!refreshed) {
        // Clear token if refresh failed
        await TokenManager.instance.clearToken();

        // Navigate to login screen
        NavigationService.navigateToAndReplace(AppRoutes.login);
      }
    } catch (e) {
      debugPrint('Error handling session expiration: $e');
      // Navigate to login screen on error
      NavigationService.navigateToAndReplace(AppRoutes.login);
    }
  }

  // Helper method to determine failure type based on status code
  static Failure _getFailureForStatusCode({
    int? statusCode,
    String? message,
    Map<String, dynamic>? errors,
  }) {
    switch (statusCode) {
      case 400:
        return _handleBadRequest(message, errors);
      case 401:
        return AuthFailure(
          message: message ?? 'Authentication required',
          code: 'unauthorized',
        );
      case 403:
        return AuthFailure(
          message: message ?? 'Access denied',
          code: 'forbidden',
        );
      case 404:
        return NetworkFailure(
          message: message ?? 'Resource not found',
          code: 'not_found',
        );
      case 422:
        return _handleValidationError(message, errors);
      case 429:
        return NetworkFailure(
          message: message ?? 'Too many requests. Please try again later.',
          code: 'rate_limit',
        );
      case 500:
      case 501:
      case 502:
      case 503:
        return NetworkFailure(
          message: message ?? 'Server error. Please try again later.',
          code: 'server_error',
        );
      default:
        return NetworkFailure(
          message: message ?? AppStrings.generalError,
          code: 'unknown_error',
        );
    }
  }

  // Helper method for handling 400 Bad Request errors
  static Failure _handleBadRequest(
    String? message,
    Map<String, dynamic>? errors,
  ) {
    if (errors != null) {
      return ValidationFailure(
        message: message ?? 'Validation error',
        errors: errors.map((k, v) => MapEntry(k, v.toString())),
        code: 'validation_error',
      );
    }
    return AuthFailure(
      message: message ?? 'Invalid request',
      code: 'invalid_request',
    );
  }

  // Helper method for handling 422 Validation errors
  static Failure _handleValidationError(
    String? message,
    Map<String, dynamic>? errors,
  ) {
    if (errors != null) {
      return ValidationFailure(
        message: message ?? 'Validation error',
        errors: errors.map((k, v) => MapEntry(k, v.toString())),
        code: 'validation_error',
      );
    }
    return AuthFailure(
      message: message ?? 'Invalid input',
      code: 'invalid_input',
    );
  }

  // Utility method to handle retry logic
  static Future<bool> retryOperation(Future<void> Function() operation) async {
    try {
      await operation();
      return true;
    } catch (e) {
      return false;
    }
  }
}
