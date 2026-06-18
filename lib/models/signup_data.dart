class SignupData {
  bool acceptedTerms = false;

  String fullName = '';
  int? age;
  String gender = '';
  double? weight;
  double? height;

  String activityLevel = '';

  String goal = '';
  double? desiredWeight;

  String hasHealthCondition = '';
  List<String> healthConditions = [];
  String otherHealthCondition = '';

  String username = '';
  String email = '';
  String password = '';

  int? userId;

  num? backendDailyCalorieGoal;
  double? backendBmi;
  String? backendBmiStatus;

  double get bmi {
    if (weight == null || height == null || height == 0) return 0;
    final heightInMeters = height! / 100;
    return weight! / (heightInMeters * heightInMeters);
  }

  String get bmiStatus {
    final value = bmi;

    if (value == 0) return 'N/A';
    if (value < 18.5) return 'Underweight';
    if (value < 25) return 'Normal';
    if (value < 30) return 'Overweight';
    return 'Obese';
  }

  int get dailyCalorieGoal {
    if (age == null || weight == null || height == null) return 0;

    final isMale = gender.toLowerCase() == 'male';

    double bmr;
    if (isMale) {
      bmr = 10 * weight! + 6.25 * height! - 5 * age! + 5;
    } else {
      bmr = 10 * weight! + 6.25 * height! - 5 * age! - 161;
    }

    final multiplier = switch (activityLevel) {
      'Not Very Active' => 1.2,
      'Lightly Active' => 1.375,
      'Active' => 1.55,
      'Very Active' => 1.725,
      _ => 1.2,
    };

    double calories = bmr * multiplier;

    final lowerGoal = goal.toLowerCase();

    if (lowerGoal == 'lose weight') {
      calories -= 500;
    } else if (lowerGoal == 'gain weight' || lowerGoal == 'gain muscles') {
      calories += 500;
    }

    if (calories < 1200) calories = 1200;

    return calories.round();
  }

  int get displayDailyCalorieGoal {
    final backendGoal = backendDailyCalorieGoal;

    if (backendGoal != null && backendGoal > 0) {
      return backendGoal.round();
    }

    return dailyCalorieGoal;
  }

  double get displayBmi {
    final backendValue = backendBmi;

    if (backendValue != null && backendValue > 0) {
      return backendValue;
    }

    return bmi;
  }

  String get displayBmiStatus {
    final backendStatus = backendBmiStatus;

    if (backendStatus != null && backendStatus.trim().isNotEmpty) {
      return backendStatus;
    }

    return bmiStatus;
  }
}