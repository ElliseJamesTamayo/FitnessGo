import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://18.138.51.204:8000';
  static const Duration timeout = Duration(seconds: 10);

  static int asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double asDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static String asString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static Future<Map<String, dynamic>> request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      late http.Response response;

      if (method == 'GET') {
        response = await http.get(uri).timeout(timeout);
      } else if (method == 'POST') {
        response = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body ?? {}),
            )
            .timeout(timeout);
      } else {
        return {
          'success': false,
          'message': 'Unsupported request method.',
        };
      }

      dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = {'message': response.body};
      }

      if (response.statusCode >= 400) {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': decoded is Map
              ? decoded['detail']?.toString() ?? 'API request failed.'
              : 'API request failed.',
          'data': decoded,
        };
      }

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return decoded.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }

      return {
        'success': true,
        'data': decoded,
      };
    } catch (error) {
      return {
        'success': false,
        'message': error.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) {
    return request(
      'POST',
      '/auth/login',
      body: {
        'username': username,
        'password': password,
      },
    );
  }

  static Future<Map<String, dynamic>> getProfile(int userId) {
    return request('GET', '/profile/$userId');
  }
}
