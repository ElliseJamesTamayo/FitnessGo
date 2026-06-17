import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static Future<void> saveUser({
    required String name,
    required int age,
    required String gender,
    required double weight,
    required double height,
    required String goal,
    required int calorieGoal,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('name', name);
    await prefs.setInt('age', age);
    await prefs.setString('gender', gender);
    await prefs.setDouble('weight', weight);
    await prefs.setDouble('height', height);
    await prefs.setString('goal', goal);
    await prefs.setInt('calorieGoal', calorieGoal);
  }

  static Future<Map<String, dynamic>> loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'name': prefs.getString('name') ?? '',
      'age': prefs.getInt('age') ?? 0,
      'gender': prefs.getString('gender') ?? '',
      'weight': prefs.getDouble('weight') ?? 0,
      'height': prefs.getDouble('height') ?? 0,
      'goal': prefs.getString('goal') ?? '',
      'calorieGoal': prefs.getInt('calorieGoal') ?? 0,
    };
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}


