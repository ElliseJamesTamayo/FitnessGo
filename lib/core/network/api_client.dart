import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
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

  static Uri _uri(String endpoint, {Map<String, dynamic>? params}) {
    final uri = Uri.parse('$baseUrl$endpoint');

    if (params == null || params.isEmpty) {
      return uri;
    }

    return uri.replace(
      queryParameters: params.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  static Future<Map<String, dynamic>> request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? params,
  }) async {
    final uri = _uri(endpoint, params: params);

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
      } else if (method == 'PUT') {
        response = await http
            .put(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body ?? {}),
            )
            .timeout(timeout);
      } else if (method == 'DELETE') {
        response = await http.delete(uri).timeout(timeout);
      } else {
        return {'success': false, 'message': 'Unsupported request method.'};
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
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }

      return {'success': true, 'data': decoded};
    } catch (error) {
      return {'success': false, 'message': error.toString()};
    }
  }

  static Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? params,
  }) {
    return request('GET', endpoint, params: params);
  }

  static Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) {
    return request('POST', endpoint, body: body);
  }

  static Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) {
    return request('PUT', endpoint, body: body);
  }

  static Future<Map<String, dynamic>> delete(String endpoint) {
    return request('DELETE', endpoint);
  }

  static Future<Map<String, dynamic>> uploadFile(
    String endpoint, {
    required String fieldName,
    required String filePath,
  }) async {
    final request = http.MultipartRequest('PUT', _uri(endpoint));

    request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    dynamic decoded;
    try {
      decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);
    } catch (_) {
      decoded = <String, dynamic>{'message': response.body};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {'success': true, 'data': decoded};
    }

    String message = 'Request failed with status ${response.statusCode}';

    if (decoded is Map && decoded['detail'] != null) {
      message = decoded['detail'].toString();
    } else if (decoded is Map && decoded['message'] != null) {
      message = decoded['message'].toString();
    }

    throw Exception(message);
  }
}
