import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../../core/network/api_client.dart';
import '../../fitnesswall/data/fitnesswall_api.dart';

class CreatePostApi {
  static int asInt(dynamic value) => FitnessWallApi.asInt(value);
  static double asDouble(dynamic value) => FitnessWallApi.asDouble(value);
  static String asString(dynamic value) => FitnessWallApi.asString(value);

  static Map<String, dynamic> _decodeResponse(
    http.Response response, {
    required String fallbackSuccessMessage,
    required String fallbackErrorMessage,
  }) {
    final success = response.statusCode >= 200 && response.statusCode < 300;

    if (response.body.trim().isEmpty) {
      return {
        'success': success,
        'message': success ? fallbackSuccessMessage : fallbackErrorMessage,
        'statusCode': response.statusCode,
      };
    }

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map) {
        final map = Map<String, dynamic>.from(decoded);

        map['success'] = map['success'] ?? success;
        map['statusCode'] = response.statusCode;

        if (map['message'] == null && map['detail'] != null) {
          map['message'] = map['detail'].toString();
        }

        if (map['message'] == null) {
          map['message'] =
              success ? fallbackSuccessMessage : fallbackErrorMessage;
        }

        return map;
      }

      return {
        'success': success,
        'message': decoded.toString(),
        'statusCode': response.statusCode,
      };
    } catch (_) {
      return {
        'success': success,
        'message': success ? fallbackSuccessMessage : response.body,
        'statusCode': response.statusCode,
      };
    }
  }

  static Future<Map<String, dynamic>> createPost({
    required int userId,
    required String postText,
    required String audience,
    String? desired,
  }) async {
    try {
      final uri = Uri.parse('${ApiClient.baseUrl}/posts/');

      final response = await http
          .post(
            uri,
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'UserId': userId,
              'PostText': postText.trim(),
              'Audience': audience,
              'Desired': desired ?? '',
            }),
          )
          .timeout(const Duration(seconds: 25));

      return _decodeResponse(
        response,
        fallbackSuccessMessage: 'Post created successfully.',
        fallbackErrorMessage: 'Failed to create post.',
      );
    } catch (error) {
      return {
        'success': false,
        'message': 'Failed to create post: $error',
      };
    }
  }

  static Future<Map<String, dynamic>> uploadPostImage({
    required int postId,
    required String imagePath,
  }) async {
    try {
      final uri = Uri.parse('${ApiClient.baseUrl}/posts/$postId/image');

      final lowerPath = imagePath.toLowerCase();

      MediaType imageType;

      if (lowerPath.endsWith('.png')) {
        imageType = MediaType('image', 'png');
      } else if (lowerPath.endsWith('.webp')) {
        imageType = MediaType('image', 'webp');
      } else if (lowerPath.endsWith('.heic')) {
        imageType = MediaType('image', 'heic');
      } else if (lowerPath.endsWith('.heif')) {
        imageType = MediaType('image', 'heif');
      } else {
        imageType = MediaType('image', 'jpeg');
      }

      final request = http.MultipartRequest('PUT', uri);

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imagePath,
          contentType: imageType,
        ),
      );

      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 40),
          );

      final response = await http.Response.fromStream(streamedResponse);

      return _decodeResponse(
        response,
        fallbackSuccessMessage: 'Post image uploaded successfully.',
        fallbackErrorMessage: 'Image upload failed.',
      );
    } catch (error) {
      return {
        'success': false,
        'message': 'Image upload failed: $error',
      };
    }
  }
}