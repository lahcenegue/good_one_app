import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<Map<String, dynamic>> post({
    required String url,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(body),
        headers: headers ?? {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        throw data['message'] ?? 'Error occurred during API call';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  static Future<Map<String, dynamic>> get({
    required String url,
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        throw data['message'] ?? 'Error occurred during API call';
      }
    } catch (e) {
      throw e.toString();
    }
  }
}
