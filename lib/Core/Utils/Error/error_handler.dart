// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:good_one_app/Core/Navigation/app_routes.dart';
// import 'package:good_one_app/Core/Navigation/navigation_service.dart';
// import 'package:good_one_app/Features/Auth/Services/token_manager.dart';

// import 'failures.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// class ErrorHandler {
//   const ErrorHandler._();

//   // Handle general exceptions
//   static Failure handleException(BuildContext context, dynamic error) {
//     if (error is Failure) return error;

//     if (error is SocketException || error is TimeoutException) {
//       return NetworkFailure(
//         context: context,
//         message: AppLocalizations.of(context)!.networkError,
//         code: 'network_error',
//       );
//     }

//     if (error is FormatException) {
//       return NetworkFailure(
//         context: context,
//         message: 'Invalid response format from server.',
//         code: 'format_error',
//       );
//     }

//     return NetworkFailure(
//       context: context,
//       message: error?.toString() ?? AppLocalizations.of(context)!.generalError,
//       code: 'unknown_error',
//     );
//   }

//   // Check if token is expired from response
//   static bool isTokenExpired(dynamic response) {
//     if (response is Map<String, dynamic>) {
//       final message = response['message']?.toString().toLowerCase() ?? '';
//       return message.contains('unauthenticated') ||
//           message.contains('expired') ||
//           message.contains('invalid token') ||
//           message.contains('token has expired');
//     }
//     return false;
//   }

//   // Handle API specific errors
//   static Failure handleApiError(BuildContext context, dynamic response) {
//     if (response is Map<String, dynamic>) {
//       final statusCode = response['statusCode'] as int?;
//       final message = response['message'] as String?;
//       final errors = response['errors'] as Map<String, dynamic>?;

//       // Check for token expiration first
//       if (isTokenExpired(response)) {
//         // Handle session expiration
//         _handleSessionExpiration(context);

//         return AuthFailure(
//           context: context,
//           message: AppLocalizations.of(context)!.sessionExpired,
//           code: 'session_expired',
//         );
//       }

//       // Handle other status codes
//       return _getFailureForStatusCode(
//         context: context,
//         statusCode: statusCode,
//         message: message,
//         errors: errors,
//       );
//     }

//     return NetworkFailure(
//       context: context,
//       message: AppLocalizations.of(context)!.generalError,
//       code: 'unknown_error',
//     );
//   }

//   // Handle session expiration
//   static Future<void> _handleSessionExpiration(BuildContext? context) async {
//     debugPrint('Handling session expiration');

//     try {
//       // Try to refresh token first
//       final refreshed = await TokenManager.instance.refreshToken();

//       if (!refreshed) {
//         // Clear token if refresh failed
//         await TokenManager.instance.clearToken();

//         // Navigate to login screen
//         NavigationService.navigateToAndReplace(AppRoutes.login);
//       }
//     } catch (e) {
//       debugPrint('Error handling session expiration: $e');
//       // Navigate to login screen on error
//       NavigationService.navigateToAndReplace(AppRoutes.login);
//     }
//   }

//   // Helper method to determine failure type based on status code
//   static Failure _getFailureForStatusCode({
//     required BuildContext context,
//     int? statusCode,
//     String? message,
//     Map<String, dynamic>? errors,
//   }) {
//     switch (statusCode) {
//       case 400:
//         return _handleBadRequest(context, message, errors);
//       case 401:
//         return AuthFailure(
//           context: context,
//           message: message ?? 'Authentication required',
//           code: 'unauthorized',
//         );
//       case 403:
//         return AuthFailure(
//           context: context,
//           message: message ?? 'Access denied',
//           code: 'forbidden',
//         );
//       case 404:
//         return NetworkFailure(
//           context: context,
//           message: message ?? 'Resource not found',
//           code: 'not_found',
//         );
//       case 422:
//         return _handleValidationError(context, message, errors);
//       case 429:
//         return NetworkFailure(
//           context: context,
//           message: message ?? 'Too many requests. Please try again later.',
//           code: 'rate_limit',
//         );
//       case 500:
//       case 501:
//       case 502:
//       case 503:
//         return NetworkFailure(
//           context: context,
//           message: message ?? 'Server error. Please try again later.',
//           code: 'server_error',
//         );
//       default:
//         return NetworkFailure(
//           context: context,
//           message: message ?? AppLocalizations.of(context)!.generalError,
//           code: 'unknown_error',
//         );
//     }
//   }

//   // Helper method for handling 400 Bad Request errors
//   static Failure _handleBadRequest(
//     BuildContext context,
//     String? message,
//     Map<String, dynamic>? errors,
//   ) {
//     if (errors != null) {
//       return ValidationFailure(
//         context: context,
//         message: message ?? 'Validation error',
//         errors: errors.map((k, v) => MapEntry(k, v.toString())),
//         code: 'validation_error',
//       );
//     }
//     return AuthFailure(
//       context: context,
//       message: message ?? 'Invalid request',
//       code: 'invalid_request',
//     );
//   }

//   // Helper method for handling 422 Validation errors
//   static Failure _handleValidationError(
//     BuildContext context,
//     String? message,
//     Map<String, dynamic>? errors,
//   ) {
//     if (errors != null) {
//       return ValidationFailure(
//         context: context,
//         message: message ?? 'Validation error',
//         errors: errors.map((k, v) => MapEntry(k, v.toString())),
//         code: 'validation_error',
//       );
//     }
//     return AuthFailure(
//       context: context,
//       message: message ?? 'Invalid input',
//       code: 'invalid_input',
//     );
//   }

//   // Utility method to handle retry logic
//   static Future<bool> retryOperation(Future<void> Function() operation) async {
//     try {
//       await operation();
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }
// }
