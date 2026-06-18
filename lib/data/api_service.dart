import '../core/network/api_client.dart';

class ApiService {
  static int asInt(dynamic value) => ApiClient.asInt(value);
  static double asDouble(dynamic value) => ApiClient.asDouble(value);
  static String asString(dynamic value) => ApiClient.asString(value);

  static Future<Map<String, dynamic>> createFood({
    required int userId,
    required String foodName,
    required double foodQuantity,
    required String mealCategory,
    required double calories,
  }) {
    return ApiClient.post(
      '/foods/',
      body: {
        'UserId': userId,
        'FoodName': foodName,
        'FoodQuantity': foodQuantity,
        'MealCategory': mealCategory,
        'Calories': calories,
      },
    );
  }

  static Future<Map<String, dynamic>> getFoodsByUserAndDate({
    required int userId,
    required String logDate,
  }) {
    return ApiClient.get(
      '/foods/user/$userId',
      params: {
        'log_date': logDate,
      },
    );
  }
}