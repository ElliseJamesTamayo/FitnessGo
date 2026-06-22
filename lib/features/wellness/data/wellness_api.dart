import '../../../core/network/api_client.dart';
import '../models/wellness_article.dart';
import '../models/wellness_exercise.dart';

class WellnessApi {
  static Future<List<WellnessArticle>> getArticles() async {
    final result = await _getWithRetry('/articles/');

    _throwIfFailed(result, fallbackMessage: 'Unable to load articles.');

    final rawArticles = result['articles'];

    if (rawArticles is! List) {
      throw const FormatException(
        'The server returned an invalid articles response.',
      );
    }

    return rawArticles.map((item) {
      if (item is! Map) {
        throw const FormatException(
          'An article from the server has an invalid format.',
        );
      }

      return WellnessArticle.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }

  static Future<List<WellnessExercise>> getExercises({
    required int userId,
  }) async {
    if (userId <= 0) {
      throw Exception('No valid logged-in user ID was found.');
    }

    final result = await _getWithRetry('/exercise/user/$userId');

    _throwIfFailed(result, fallbackMessage: 'Unable to load exercises.');

    final rawExercises = result['exercises'];

    if (rawExercises is! List) {
      throw const FormatException(
        'The server returned an invalid exercises response.',
      );
    }

    return rawExercises.map((item) {
      if (item is! Map) {
        throw const FormatException(
          'An exercise from the server has an invalid format.',
        );
      }

      return WellnessExercise.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }

  static Future<Map<String, dynamic>> getExerciseDetails({
    required int userExerciseId,
  }) async {
    if (userExerciseId <= 0) {
      throw Exception('No valid exercise ID was found.');
    }

    final result = await _getWithRetry('/exercise/$userExerciseId');

    _throwIfFailed(result, fallbackMessage: 'Unable to load exercise details.');

    final nestedExercise = result['exercise'] ?? result['data'];

    if (nestedExercise is Map) {
      return Map<String, dynamic>.from(nestedExercise);
    }

    return Map<String, dynamic>.from(result);
  }

  static Future<List<Map<String, dynamic>>> getSavedArticles({
    required int userId,
  }) async {
    if (userId <= 0) {
      throw Exception('No valid logged-in user ID was found.');
    }

    final result = await _getWithRetry('/articles/saved/user/$userId');

    _throwIfFailed(result, fallbackMessage: 'Unable to load saved articles.');

    final rawItems =
        result['saved_articles'] ??
        result['savedArticles'] ??
        result['data'] ??
        [];

    final mapped = _mapList(rawItems, 'saved articles');

    return mapped.where(_isRealSavedArticleRecord).toList();
  }

  static Future<List<Map<String, dynamic>>> getSavedExercises({
    required int userId,
  }) async {
    if (userId <= 0) {
      throw Exception('No valid logged-in user ID was found.');
    }

    final result = await _getWithRetry('/exercise/saved/user/$userId');

    _throwIfFailed(result, fallbackMessage: 'Unable to load saved exercises.');

    final rawItems =
        result['saved_exercises'] ??
        result['savedExercises'] ??
        result['exercises'] ??
        result['data'] ??
        [];

    return _mapList(rawItems, 'saved exercises');
  }

  static Future<Map<String, dynamic>> saveArticle({
    required int userId,
    required WellnessArticle article,
  }) async {
    if (userId <= 0) {
      throw Exception('No valid logged-in user ID was found.');
    }

    final result = await ApiClient.post(
      '/articles/saved',
      body: {
        'UserId': userId,
        'ArticleId': article.articleId,
        'category': article.category,
        'title': article.title,
        'author': article.author,
        'date': article.date,
        'body': article.body,
        'image': article.image,
      },
    );

    _throwIfFailed(result, fallbackMessage: 'Unable to save the article.');

    return result;
  }

  static int _cleanReps(String value) {
    final match = RegExp(r'\d+').firstMatch(value);

    if (match == null) {
      return 12;
    }

    return int.tryParse(match.group(0)!) ?? 12;
  }

  static Future<Map<String, dynamic>> saveExercise({
    required int userId,
    required WellnessExercise exercise,
  }) async {
    if (userId <= 0) {
      throw Exception('No valid logged-in user ID was found.');
    }

    final result = await ApiClient.post(
      '/exercise/saved',
      body: {
        'UserId': userId,
        'UserExerciseId': exercise.userExerciseId > 0
            ? exercise.userExerciseId
            : null,
        'name': exercise.name,
        'difficulty': exercise.difficulty,
        'program_name': exercise.programName,
        'sets': exercise.sets.toString(),
        'reps': _cleanReps(exercise.reps),
        'rest_seconds': exercise.restSeconds.toString(),
      },
    );

    _throwIfFailed(result, fallbackMessage: 'Unable to save the exercise.');

    return result;
  }

  static Future<Map<String, dynamic>> deleteSavedArticle({
    required int savedArticleId,
  }) async {
    if (savedArticleId <= 0) {
      throw Exception('No valid saved article ID was found.');
    }

    final result = await ApiClient.delete('/articles/saved/$savedArticleId');

    _throwIfFailed(result, fallbackMessage: 'Unable to delete saved article.');

    return result;
  }

  static Future<Map<String, dynamic>> deleteSavedExercise({
    required int savedExerciseId,
  }) async {
    if (savedExerciseId <= 0) {
      throw Exception('No valid saved exercise ID was found.');
    }

    final result = await ApiClient.delete('/exercise/saved/$savedExerciseId');

    _throwIfFailed(result, fallbackMessage: 'Unable to delete saved exercise.');

    return result;
  }

  static bool _isRealSavedArticleRecord(Map<String, dynamic> item) {
    return _asInt(
          item['SavedId'] ??
              item['savedId'] ??
              item['saved_id'] ??
              item['SavedArticleId'] ??
              item['savedArticleId'] ??
              item['saved_article_id'] ??
              item['SavedArticleByUserId'] ??
              item['savedArticleByUserId'] ??
              item['saved_article_by_user_id'] ??
              item['SavedArticleByUserID'],
        ) >
        0;
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.round() ?? 0;
    }
    return 0;
  }

  static Future<Map<String, dynamic>> _getWithRetry(String endpoint) async {
    Map<String, dynamic> lastResult = <String, dynamic>{};

    for (int attempt = 1; attempt <= 3; attempt++) {
      final result = await ApiClient.get(endpoint);
      lastResult = result;

      if (result['success'] != false) {
        return result;
      }

      if (!_shouldRetry(result) || attempt == 3) {
        return result;
      }

      await Future.delayed(Duration(milliseconds: 700 * attempt));
    }

    return lastResult;
  }

  static bool _shouldRetry(Map<String, dynamic> result) {
    final statusCode = ApiClient.asInt(result['statusCode']);

    if (statusCode == 500 ||
        statusCode == 502 ||
        statusCode == 503 ||
        statusCode == 504) {
      return true;
    }

    final message = ApiClient.asString(result['message']).toLowerCase();

    return message.contains('cannot connect') ||
        message.contains('connection') ||
        message.contains('timed out') ||
        message.contains('timeout') ||
        message.contains('server');
  }

  static List<Map<String, dynamic>> _mapList(dynamic rawItems, String label) {
    if (rawItems is! List) {
      throw FormatException('The server returned an invalid $label response.');
    }

    return rawItems
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static void _throwIfFailed(
    Map<String, dynamic> result, {
    required String fallbackMessage,
  }) {
    if (result['success'] == false) {
      throw Exception(
        result['message']?.toString() ??
            result['detail']?.toString() ??
            fallbackMessage,
      );
    }
  }
}
