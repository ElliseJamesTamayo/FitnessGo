import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminApi {
  static const String baseUrl = 'http://18.138.51.204:8000';
  static const Duration timeout = Duration(seconds: 12);

  static Future<Map<String, dynamic>> _postRaw(String endpoint, {Map<String, dynamic>? body}) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body ?? <String, dynamic>{}),
    ).timeout(timeout);

    dynamic decoded;
    try {
      decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    } catch (_) {
      decoded = {'message': response.body};
    }

    if (response.statusCode >= 400) {
      return {
        'success': false,
        'status_code': response.statusCode,
        'message': decoded is Map ? decoded['detail'] ?? decoded['message'] ?? 'Admin API request failed' : 'Admin API request failed',
        'data': decoded,
      };
    }

    if (decoded is Map<String, dynamic>) return decoded;
    return {'success': true, 'data': decoded};
  }

  static Future<Map<String, dynamic>> _post(String endpoint, {Map<String, dynamic>? body}) async {
    return _postRaw(endpoint, body: body);
  }

  static List<Map<String, dynamic>> dataAsList(Map<String, dynamic> result) {
    final raw = result['data'];
    if (raw is List) {
      return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return <Map<String, dynamic>>[];
  }

  static int dataAsInt(Map<String, dynamic> result) => asInt(result['data']);

  static String asString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final text = value.toString();
    if (text == 'null') return fallback;
    return text;
  }

  static int asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value.toString()) ?? 0;
  }

  static Future<Map<String, dynamic>> getActiveFeedwallUsersToday() => _post('/get-active-feedwall-users-today');
  static Future<Map<String, dynamic>> getFeedwallUsersToday() => _post('/get-feedwall-users-today');
  static Future<Map<String, dynamic>> autoDeactivateInactiveAccounts() => _post('/auto-deactivate-inactive-accounts');
  static Future<Map<String, dynamic>> getActiveAccounts() => _post('/get-active-accounts');
  static Future<Map<String, dynamic>> getViolatorUsers() => _post('/get-violator-users');
  static Future<Map<String, dynamic>> getDeactivatedAccounts() => _post('/get-deactivated-accounts');

  static Future<Map<String, dynamic>> getPostsByUserAndDate({required int userId, required String selectedDate}) {
    return _post('/get-posts-by-user-and-date', body: {'args': [userId, selectedDate]});
  }

  static Future<Map<String, dynamic>> getPostsTodayByUser({required int userId}) {
    return _post('/get-posts-today-by-user', body: {'args': [userId]});
  }

  static Future<Map<String, dynamic>> incrementUserViolation({required int userId}) {
    return _post('/increment-user-violation', body: {'args': [userId]});
  }

  static Future<Map<String, dynamic>> setLoginNotice({required int userId, required String notice}) {
    return _post('/set-login-notice', body: {'args': [userId, notice]});
  }
}

