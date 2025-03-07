import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../../Config/app_config.dart';
import 'api_response.dart';
import '../../presentation/resources/app_strings.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// The default timeout duration for API requests, from AppConfig.
  final Duration _timeout = AppConfig.apiTimeout;

  static ApiService get instance => _instance;

  Future<ApiResponse<T>> _executeRequest<T>({
    required Future<http.Response> Function(String? token) requestFunction,
    required T Function(dynamic) fromJson,
    String? token,
    int maxRetries = 2,
  }) async {
    int retryCount = 0;
    while (retryCount <= maxRetries) {
      try {
        final response =
            await requestFunction(token).timeout(AppConfig.apiTimeout);
        return _processResponse(response, fromJson);
      } catch (e) {
        if (e is TimeoutException && retryCount < maxRetries) {
          retryCount++;
          print('Retry attempt $retryCount for network timeout');
          await Future.delayed(
              Duration(seconds: 1 * retryCount)); // Exponential backoff
          continue;
        }
        print('API request failed after retries: $e');
        return ApiResponse.error(AppStrings.networkError);
      }
    }
    return ApiResponse.error(AppStrings.networkError);
  }

  Map<String, String> _getHeaders(String? token) {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Accept-Encoding': 'gzip, deflate, br',
      'Connection': 'keep-alive',
      'User-Agent': 'Flutter/1.0',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    print('Request Headers: $headers');
    return headers;
  }

  Future<ApiResponse<T>> post<T>({
    required String url,
    required Map<String, dynamic> body,
    required T Function(dynamic) fromJson,
    String? token,
  }) async {
    print('POST Request to: $url');
    print('Request Body: $body');

    return _executeRequest<T>(
      requestFunction: (currentToken) => http
          .post(
            Uri.parse(url),
            body: jsonEncode(body),
            headers: _getHeaders(currentToken),
          )
          .timeout(_timeout),
      fromJson: fromJson,
      token: token,
    );
  }

  Future<ApiResponse<T>> get<T>({
    required String url,
    required T Function(dynamic) fromJson,
    String? token,
  }) async {
    debugPrint('GET Request to: $url');

    return _executeRequest<T>(
      requestFunction: (currentToken) => http
          .get(
            Uri.parse(url),
            headers: _getHeaders(currentToken),
          )
          .timeout(_timeout),
      fromJson: fromJson,
      token: token,
    );
  }

  Future<ApiResponse<T>> postMultipart<T>({
    required String url,
    required Map<String, String> fields,
    required Map<String, File> files,
    required T Function(dynamic) fromJson,
    String? token,
  }) async {
    print('Multipart POST Request to: $url');
    print('Fields: $fields');

    Future<http.Response> multipartRequest(String? currentToken) async {
      final request = http.MultipartRequest('POST', Uri.parse(url))
        ..headers.addAll(_getHeaders(currentToken))
        ..fields.addAll(fields);

      for (var entry in files.entries) {
        request.files.add(
          await http.MultipartFile.fromPath(entry.key, entry.value.path),
        );
      }

      final streamedResponse = await request.send().timeout(_timeout);
      return http.Response.fromStream(streamedResponse);
    }

    return _executeRequest<T>(
      requestFunction: multipartRequest,
      fromJson: fromJson,
      token: token,
    );
  }

  Future<ApiResponse<T>> _processResponse<T>(
    http.Response response,
    T Function(dynamic) fromJson,
  ) async {
    try {
      final dynamic decodedBody = jsonDecode(response.body);
      debugPrint('API Response Status Code: ${response.statusCode}');
      debugPrint('API Response Body: $decodedBody');

      // First check if it's a successful response (200-299)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decodedBody is Map<String, dynamic>) {
          if (decodedBody.containsKey('data')) {
            return ApiResponse.success(fromJson(decodedBody['data']));
          }
          return ApiResponse.success(fromJson(decodedBody));
        } else if (decodedBody is List) {
          return ApiResponse.success(fromJson(decodedBody));
        }
        return ApiResponse.success(fromJson(decodedBody));
      }

      // Check for token expiration first
      if (_isTokenExpired(response)) {
        print('Token expired or invalid detected');
        return ApiResponse.error(AppStrings.sessionExpired);
      }

      // Handle other errors
      if (decodedBody is Map<String, dynamic>) {
        final message = decodedBody['message']?.toString() ?? '';

        // Handle other specific error codes
        switch (response.statusCode) {
          case 400:
            return ApiResponse.error(message.isEmpty ? 'Bad Request' : message);
          case 403:
            return ApiResponse.error(
                message.isEmpty ? 'Access Denied' : message);
          case 404:
            return ApiResponse.error(message.isEmpty ? 'Not Found' : message);
          case 422:
            return ApiResponse.error(
                message.isEmpty ? 'Validation Error' : message);
          case 429:
            return ApiResponse.error('Too Many Requests');
          case 500:
          case 501:
          case 502:
          case 503:
            return ApiResponse.error(AppStrings.serverError);
          default:
            return ApiResponse.error(
                message.isEmpty ? AppStrings.generalError : message);
        }
      }

      return ApiResponse.error(AppStrings.generalError);
    } catch (e) {
      print('Response processing error: $e');
      return ApiResponse.error(AppStrings.generalError);
    }
  }

// Add this helper method to check for token expiration
  bool _isTokenExpired(http.Response response) {
    try {
      if (response.statusCode == 401) {
        final body = jsonDecode(response.body);
        final message = body['message']?.toString().toLowerCase() ?? '';
        return message.contains('expired') ||
            message.contains('invalid token') ||
            message.contains('unauthenticated');
      }
      return false;
    } catch (e) {
      print('Error checking token expiration: $e');
      return false;
    }
  }
}
