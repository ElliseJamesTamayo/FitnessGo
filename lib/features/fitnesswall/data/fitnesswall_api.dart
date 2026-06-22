import '../../../core/network/api_client.dart';

class FitnessWallApi {
  static int asInt(dynamic value) => ApiClient.asInt(value);
  static double asDouble(dynamic value) => ApiClient.asDouble(value);
  static String asString(dynamic value) => ApiClient.asString(value);

  static Future<Map<String, dynamic>> getAllPosts() {
    return ApiClient.get('/posts/');
  }

  static Future<Map<String, dynamic>> getPost({required int postId}) {
    return ApiClient.get('/posts/$postId');
  }

  static Future<Map<String, dynamic>> getUserPosts({required int userId}) {
    return ApiClient.get('/posts/user/$userId/all');
  }

  static Future<Map<String, dynamic>> createPost({
    required int userId,
    required String postText,
    required String audience,
    String? desired,
  }) {
    return ApiClient.post(
      '/posts/',
      body: {
        'UserId': userId,
        'PostText': postText.trim(),
        'Audience': audience,
        'Desired': desired,
      },
    );
  }

  static Future<Map<String, dynamic>> updatePost({
    required int postId,
    required String postText,
  }) {
    return ApiClient.put('/posts/$postId', body: {'PostText': postText.trim()});
  }

  static Future<Map<String, dynamic>> updatePostAudience({
    required int postId,
    required String audience,
  }) {
    return ApiClient.put(
      '/posts/$postId/audience',
      body: {'Audience': audience},
    );
  }

  static Future<Map<String, dynamic>> deletePost({required int postId}) {
    return ApiClient.delete('/posts/$postId');
  }

  static List<Map<String, dynamic>> extractPostList(
    Map<String, dynamic> result,
  ) {
    final possibleLists = [
      result['posts'],
      result['post'],
      result['data'],
      result['items'],
      result['results'],
    ];

    for (final item in possibleLists) {
      if (item is List) {
        return item
            .whereType<Map>()
            .map((post) => Map<String, dynamic>.from(post))
            .toList();
      }

      if (item is Map) {
        final nestedLists = [
          item['posts'],
          item['post'],
          item['data'],
          item['items'],
          item['results'],
        ];

        for (final nestedItem in nestedLists) {
          if (nestedItem is List) {
            return nestedItem
                .whereType<Map>()
                .map((post) => Map<String, dynamic>.from(post))
                .toList();
          }
        }
      }
    }

    if (result.containsKey('PostId') || result.containsKey('PostText')) {
      return [result];
    }

    return [];
  }

  static bool isPublicPost(Map<String, dynamic> post) {
    final audience = asString(
      post['Audience'] ?? post['audience'],
    ).trim().toLowerCase();

    return audience.isEmpty || audience == 'public';
  }

  static String readPostName(Map<String, dynamic> post) {
    final name = asString(
      post['Fullname'] ??
          post['fullname'] ??
          post['Username'] ??
          post['username'] ??
          post['name'],
    ).trim();

    return name.isEmpty ? 'User' : name;
  }

  static String readPostContent(Map<String, dynamic> post) {
    return asString(
      post['PostText'] ??
          post['postText'] ??
          post['post_text'] ??
          post['content'] ??
          post['body'],
    );
  }

  static String readPostTime(Map<String, dynamic> post) {
    final rawTime = asString(
      post['time'] ??
          post['Created_at'] ??
          post['Created_At'] ??
          post['created_at'] ??
          post['createdAt'],
    ).trim();

    if (rawTime.isEmpty) return 'Just now';

    if (rawTime.toLowerCase() == 'just now') {
      return 'Just now';
    }

    final parsed = parseServerPostTime(rawTime);

    if (parsed == null) return rawTime;

    final now = DateTime.now();
    var difference = now.difference(parsed);

    if (difference.isNegative) {
      difference = Duration.zero;
    }

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m';
    if (difference.inDays < 1) return '${difference.inHours}h';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays}d';

    final month = parsed.month.toString().padLeft(2, '0');
    final day = parsed.day.toString().padLeft(2, '0');

    return '${parsed.year}-$month-$day';
  }

  static DateTime? parseServerPostTime(String rawTime) {
    final trimmed = rawTime.trim();

    if (trimmed.isEmpty) {
      return null;
    }

    final hasTimezone = RegExp(r'(Z|z|[+-]\d{2}:?\d{2})$').hasMatch(trimmed);

    if (hasTimezone) {
      return DateTime.tryParse(trimmed)?.toLocal();
    }

    final normalized = trimmed.contains('T')
        ? trimmed
        : trimmed.replaceFirst(' ', 'T');

    final parsedAsUtc = DateTime.tryParse('${normalized}Z');

    if (parsedAsUtc != null) {
      return parsedAsUtc.toLocal();
    }

    return DateTime.tryParse(trimmed);
  }
}
