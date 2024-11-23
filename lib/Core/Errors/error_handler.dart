import 'dart:async';
import 'dart:io';

import 'failures.dart';

class ErrorHandler {
  static Failure handleException(dynamic error) {
    if (error is Failure) return error;

    if (error is SocketException || error is TimeoutException) {
      return const NetworkFailure(
        message:
            'Network connection error. Please check your internet connection.',
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
      message: error?.toString() ?? 'An unexpected error occurred.',
      code: 'unknown_error',
    );
  }

  static Failure handleApiError(Map<String, dynamic> response) {
    final statusCode = response['statusCode'] as int?;
    final message = response['message'] as String?;
    final errors = response['errors'] as Map<String, dynamic>?;

    switch (statusCode) {
      case 400:
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
          message: message ?? 'An unexpected error occurred',
          code: 'unknown_error',
        );
    }
  }
}
