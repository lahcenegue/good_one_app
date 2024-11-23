import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool success;

  ApiResponse({
    this.data,
    this.error,
    this.success = false,
  });

  factory ApiResponse.success(T data) => ApiResponse(
        data: data,
        success: true,
      );

  factory ApiResponse.error(String message) => ApiResponse(
        error: message,
        success: false,
      );
}

class ApiService {
  static const Duration _timeout = Duration(seconds: 30);

  // Generic POST method
  static Future<ApiResponse<T>> post<T>({
    required String url,
    required Map<String, dynamic> body,
    required T Function(Map<String, dynamic>) fromJson,
    String? token,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(url),
            body: jsonEncode(body),
            headers: _getHeaders(token),
          )
          .timeout(_timeout);

      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse.error(_getErrorMessage(e));
    }
  }

  // Generic GET method
  static Future<ApiResponse<T>> get<T>({
    required String url,
    required T Function(Map<String, dynamic>) fromJson,
    String? token,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: _getHeaders(token),
          )
          .timeout(_timeout);

      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse.error(_getErrorMessage(e));
    }
  }

  //multipart requests
  static Future<ApiResponse<T>> postMultipart<T>({
    required String url,
    required Map<String, String> fields,
    required Map<String, File> files,
    required T Function(Map<String, dynamic>) fromJson,
    String? token,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      // Add headers
      request.headers.addAll(_getHeaders(token, true));

      // Add text fields
      request.fields.addAll(fields);

      // Add files
      for (var entry in files.entries) {
        request.files.add(
          await http.MultipartFile.fromPath(
            entry.key,
            entry.value.path,
          ),
        );
      }

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse.error(_getErrorMessage(e));
    }
  }

  // Helper Methods
  static Map<String, String> _getHeaders(
      [String? token, bool isMultipart = false]) {
    final headers = {
      'Accept': 'application/json',
    };

    // Only add Content-Type for non-multipart requests
    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse.success(fromJson(body));
    }

    return ApiResponse.error(body['message'] ?? 'An error occurred');
  }

  static String _getErrorMessage(dynamic error) {
    if (error is TimeoutException) {
      return 'Connection timeout. Please try again.';
    }
    if (error is SocketException) {
      return 'No internet connection.';
    }
    return error.toString();
  }
}
