import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'http://18.138.51.204:8000';
  static const Duration timeout = Duration(seconds: 15);

  static int asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();

    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.round() ?? 0;
    }

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
    final cleanBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';

    final uri = Uri.parse('$cleanBaseUrl$cleanEndpoint');

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

    print('================ API REQUEST ================');
    print('METHOD: $method');
    print('URL: $uri');
    print('BODY: ${body == null ? '{}' : jsonEncode(body)}');
    print('=============================================');

    try {
      late http.Response response;

      if (method == 'GET') {
        response = await http.get(uri).timeout(timeout);
      } else if (method == 'POST') {
        response = await http
            .post(
              uri,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode(body ?? {}),
            )
            .timeout(timeout);
      } else if (method == 'PUT') {
        response = await http
            .put(
              uri,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode(body ?? {}),
            )
            .timeout(timeout);
      } else if (method == 'DELETE') {
        response = await http.delete(uri).timeout(timeout);
      } else {
        return {
          'success': false,
          'message': 'Unsupported request method.',
        };
      }

      print('================ API RESPONSE ===============');
      print('STATUS: ${response.statusCode}');
      print('URL: $uri');
      print('BODY: ${response.body}');
      print('=============================================');

      dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = {
          'message': response.body,
        };
      }

      if (response.statusCode >= 400) {
        String errorMessage = 'API request failed.';

        if (decoded is Map) {
          final detail = decoded['detail'];

          if (detail is String) {
            errorMessage = detail;
          } else if (detail is List || detail is Map) {
            errorMessage = jsonEncode(detail);
          } else if (decoded['message'] != null) {
            errorMessage = decoded['message'].toString();
          }
        }

        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': errorMessage,
          'url': uri.toString(),
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
        'statusCode': response.statusCode,
        'url': uri.toString(),
        'data': decoded,
      };
    } catch (error) {
      print('================ API ERROR ==================');
      print('URL: $uri');
      print('ERROR: $error');
      print('=============================================');

      return {
        'success': false,
        'message': error.toString(),
        'url': uri.toString(),
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
    required String filePath,
    String fieldName = 'file',
    String? fileField,
    Map<String, String>? fields,
  }) async {
    final uri = _uri(endpoint);
    final uploadField = fileField ?? fieldName;

    print('================ API UPLOAD =================');
    print('URL: $uri');
    print('FILE FIELD: $uploadField');
    print('FILE PATH: $filePath');
    print('FIELDS: ${fields ?? {}}');
    print('=============================================');

    try {
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Accept': 'application/json',
      });

      if (fields != null && fields.isNotEmpty) {
        request.fields.addAll(fields);
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          uploadField,
          filePath,
        ),
      );

      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      print('================ UPLOAD RESPONSE =============');
      print('STATUS: ${response.statusCode}');
      print('URL: $uri');
      print('BODY: ${response.body}');
      print('=============================================');

      dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = {
          'message': response.body,
        };
      }

      if (response.statusCode >= 400) {
        String errorMessage = 'Upload failed.';

        if (decoded is Map) {
          final detail = decoded['detail'];

          if (detail is String) {
            errorMessage = detail;
          } else if (detail is List || detail is Map) {
            errorMessage = jsonEncode(detail);
          } else if (decoded['message'] != null) {
            errorMessage = decoded['message'].toString();
          }
        }

        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': errorMessage,
          'url': uri.toString(),
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
        'statusCode': response.statusCode,
        'url': uri.toString(),
        'data': decoded,
      };
    } catch (error) {
      print('================ UPLOAD ERROR ===============');
      print('URL: $uri');
      print('ERROR: $error');
      print('=============================================');

      return {
        'success': false,
        'message': error.toString(),
        'url': uri.toString(),
      };
    }
  }
}
