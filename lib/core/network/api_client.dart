import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

  static dynamic _decodeResponseBody(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    try {
      return jsonDecode(body);
    } catch (_) {
      return {'message': body};
    }
  }

  static String _extractErrorMessage(dynamic decoded) {
    if (decoded is Map) {
      final detail = decoded['detail'];

      if (detail is String && detail.trim().isNotEmpty) {
        return detail.trim();
      }

      if (detail is List && detail.isNotEmpty) {
        final messages = detail
            .map((item) {
              if (item is Map) {
                final msg = item['msg']?.toString() ?? '';
                final loc = item['loc'];

                if (loc is List && loc.isNotEmpty && msg.isNotEmpty) {
                  return '${loc.join('.')}: $msg';
                }

                return msg;
              }

              return item.toString();
            })
            .where((message) => message.trim().isNotEmpty)
            .join('\n');

        if (messages.trim().isNotEmpty) {
          return messages.trim();
        }
      }

      final message = decoded['message'];

      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString().trim();
      }

      final error = decoded['error'];

      if (error != null && error.toString().trim().isNotEmpty) {
        return error.toString().trim();
      }
    }

    if (decoded != null && decoded.toString().trim().isNotEmpty) {
      return decoded.toString().trim();
    }

    return 'API request failed.';
  }

  static String _friendlyConnectionError(Object error) {
    final errorText = error.toString();

    if (error is TimeoutException) {
      return 'Connection timed out. Please check if the server is running.';
    }

    if (error is SocketException) {
      return 'Cannot connect to the server. Please check your internet connection or API server.';
    }

    if (errorText.contains('Connection refused')) {
      return 'Connection refused. The API server may not be running.';
    }

    if (errorText.contains('Connection closed') ||
        errorText.contains('Connection closed before full header was received')) {
      return 'The server connection closed unexpectedly. Please try again.';
    }

    if (errorText.contains('Failed host lookup')) {
      return 'Cannot find the server host. Please check the base URL.';
    }

    return errorText;
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
        response = await http.get(
          uri,
          headers: const {'Accept': 'application/json'},
        ).timeout(timeout);
      } else if (method == 'POST') {
        response = await http
            .post(
              uri,
              headers: const {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(body ?? {}),
            )
            .timeout(timeout);
      } else if (method == 'PUT') {
        response = await http
            .put(
              uri,
              headers: const {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(body ?? {}),
            )
            .timeout(timeout);
      } else if (method == 'DELETE') {
        response = await http.delete(
          uri,
          headers: const {'Accept': 'application/json'},
        ).timeout(timeout);
      } else {
        return {'success': false, 'message': 'Unsupported request method.'};
      }

      final decoded = _decodeResponseBody(response.body);

      if (response.statusCode >= 400) {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': _extractErrorMessage(decoded),
          'data': decoded,
        };
      }

      if (decoded is Map<String, dynamic>) {
        decoded['success'] = decoded['success'] ?? true;
        decoded['statusCode'] = response.statusCode;
        return decoded;
      }

      if (decoded is Map) {
        final mapped = decoded.map(
          (key, value) => MapEntry(key.toString(), value),
        );

        mapped['success'] = mapped['success'] ?? true;
        mapped['statusCode'] = response.statusCode;

        return mapped;
      }

      return {
        'success': true,
        'statusCode': response.statusCode,
        'data': decoded,
      };
    } catch (error) {
      return {
        'success': false,
        'message': _friendlyConnectionError(error),
      };
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
    try {
      final request = http.MultipartRequest('PUT', _uri(endpoint));

      request.headers.addAll(
        const {'Accept': 'application/json'},
      );

      request.files.add(
        await http.MultipartFile.fromPath(fieldName, filePath),
      );

      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      final decoded = _decodeResponseBody(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is Map<String, dynamic>) {
          decoded['success'] = decoded['success'] ?? true;
          decoded['statusCode'] = response.statusCode;
          return decoded;
        }

        if (decoded is Map) {
          final mapped = decoded.map(
            (key, value) => MapEntry(key.toString(), value),
          );

          mapped['success'] = mapped['success'] ?? true;
          mapped['statusCode'] = response.statusCode;

          return mapped;
        }

        return {
          'success': true,
          'statusCode': response.statusCode,
          'data': decoded,
        };
      }

      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': _extractErrorMessage(decoded),
        'data': decoded,
      };
    } catch (error) {
      return {
        'success': false,
        'message': _friendlyConnectionError(error),
      };
    }
  }
}
