import '../../core/network/api_client.dart';

class WellnessHubApi {
  static int asInt(dynamic value) => ApiClient.asInt(value);
  static double asDouble(dynamic value) => ApiClient.asDouble(value);
  static String asString(dynamic value) => ApiClient.asString(value);

  // ARTICLES
  static Future<Map<String, dynamic>> getArticles() {
    return ApiClient.get('/articles/');
  }

  static Future<Map<String, dynamic>> getArticleById({
    required int articleId,
  }) {
    return ApiClient.get('/articles/$articleId');
  }

  // PROFILE
  // Used to get the logged-in user's Goal, for example: gain_weight, lose_weight, maintain_weight.
  static Future<Map<String, dynamic>> getProfile({
    required int userId,
  }) {
    return ApiClient.get('/profile/$userId');
  }

  // EXERCISES
  // Your shared Wellness Hub exercises are stored with UserId = 0,
  // so this fetches the public exercise library.
  static Future<Map<String, dynamic>> getPublicExercises() {
    return ApiClient.get('/exercise/user/0');
  }

  // User-specific exercises, if you need them later.
  static Future<Map<String, dynamic>> getUserExercises({
    required int userId,
  }) {
    return ApiClient.get('/exercise/user/$userId');
  }

  static Future<Map<String, dynamic>> getExerciseById({
    required int exerciseId,
  }) {
    return ApiClient.get('/exercise/$exerciseId');
  }

  static Future<Map<String, dynamic>> getSavedExercises({
    required int userId,
  }) {
    return ApiClient.get('/exercise/saved/user/$userId');
  }

  // Save exercise into the user's Activity Log / saved workouts.
  // I included both ExerciseId and UserExerciseId because some FastAPI schemas use one or the other.
  static Future<Map<String, dynamic>> saveExercise({
    required int userId,
    required int exerciseId,
  }) {
    return ApiClient.post(
      '/exercise/saved',
      body: {
        'UserId': userId,
        'ExerciseId': exerciseId,
        'UserExerciseId': exerciseId,
      },
    );
  }

  static Future<Map<String, dynamic>> deleteSavedExercise({
    required int savedExerciseId,
  }) {
    return ApiClient.delete('/exercise/saved/$savedExerciseId');
  }
}
