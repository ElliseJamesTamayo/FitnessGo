import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthStore {
  static const _accountsKey = 'fitnessgo_accounts_v1';
  static const _currentEmailKey = 'fitnessgo_current_email';

  static const _fullNameKey = 'signup_full_name';
  static const _emailKey = 'signup_email';
  static const _passwordKey = 'signup_password';
  static const _dailyGoalKey = 'signup_daily_goal';

  static const _goalKey = 'signup_goal';
  static const _desiredWeightKey = 'signup_desired_weight';
  static const _bmiKey = 'signup_bmi';
  static const _bmiStatusKey = 'signup_bmi_status';
  static const _activityLevelKey = 'signup_activity_level';
  static const _healthConditionKey = 'signup_health_condition';

  static const _ageKey = 'signup_age';
  static const _genderKey = 'signup_gender';
  static const _heightKey = 'signup_height';
  static const _weightKey = 'signup_weight';

  static String _cleanEmail(String email) {
    return email.trim().toLowerCase();
  }

  static Future<Map<String, dynamic>> _loadAccounts(
    SharedPreferences prefs,
  ) async {
    final raw = prefs.getString(_accountsKey);

    if (raw == null || raw.trim().isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return decoded.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }
    } catch (_) {
      return {};
    }

    return {};
  }

  static Future<void> _saveAccounts(
    SharedPreferences prefs,
    Map<String, dynamic> accounts,
  ) async {
    await prefs.setString(_accountsKey, jsonEncode(accounts));
  }

  static Future<String> _getCurrentEmail(SharedPreferences prefs) async {
    final current = prefs.getString(_currentEmailKey) ?? '';

    if (current.trim().isNotEmpty) {
      return _cleanEmail(current);
    }

    return _cleanEmail(prefs.getString(_emailKey) ?? '');
  }

  static Map<String, dynamic>? _accountByEmail(
    Map<String, dynamic> accounts,
    String email,
  ) {
    final cleanEmail = _cleanEmail(email);

    final account = accounts[cleanEmail];

    if (account is Map<String, dynamic>) {
      return account;
    }

    if (account is Map) {
      return account.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }

    return null;
  }

  static double _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _asString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static Future<Map<String, dynamic>?> _currentAccount(
    SharedPreferences prefs,
  ) async {
    final accounts = await _loadAccounts(prefs);
    final email = await _getCurrentEmail(prefs);
    return _accountByEmail(accounts, email);
  }

  static Future<void> saveSignup({
    required String fullName,
    required String email,
    required String password,
    required int dailyGoal,
    String goal = '',
    double desiredWeight = 0,
    double bmi = 0,
    String bmiStatus = '',
    String activityLevel = '',
    String healthCondition = '',
    int age = 0,
    String gender = '',
    double height = 0,
    double weight = 0,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanEmail = _cleanEmail(email);
    final accounts = await _loadAccounts(prefs);

    final account = <String, dynamic>{
      'fullName': fullName.trim(),
      'email': cleanEmail,
      'password': password.trim(),
      'dailyGoal': dailyGoal,
      'goal': goal.trim(),
      'desiredWeight': desiredWeight.toDouble(),
      'bmi': bmi.toDouble(),
      'bmiStatus': bmiStatus.trim(),
      'activityLevel': activityLevel.trim(),
      'healthCondition': healthCondition.trim(),
      'age': age,
      'gender': gender.trim(),
      'height': height.toDouble(),
      'weight': weight.toDouble(),
    };

    accounts[cleanEmail] = account;

    await _saveAccounts(prefs, accounts);
    await prefs.setString(_currentEmailKey, cleanEmail);

    await prefs.setString(_fullNameKey, fullName.trim());
    await prefs.setString(_emailKey, cleanEmail);
    await prefs.setString(_passwordKey, password.trim());
    await prefs.setInt(_dailyGoalKey, dailyGoal);

    await prefs.setString(_goalKey, goal.trim());
    await prefs.setDouble(_desiredWeightKey, desiredWeight.toDouble());
    await prefs.setDouble(_bmiKey, bmi.toDouble());
    await prefs.setString(_bmiStatusKey, bmiStatus.trim());
    await prefs.setString(_activityLevelKey, activityLevel.trim());
    await prefs.setString(_healthConditionKey, healthCondition.trim());

    await prefs.setInt(_ageKey, age);
    await prefs.setString(_genderKey, gender.trim());
    await prefs.setDouble(_heightKey, height.toDouble());
    await prefs.setDouble(_weightKey, weight.toDouble());
  }

  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanEmail = _cleanEmail(email);
    final cleanPassword = password.trim();

    final accounts = await _loadAccounts(prefs);
    final account = _accountByEmail(accounts, cleanEmail);

    if (account != null) {
      final savedPassword = _asString(account['password']).trim();

      if (savedPassword == cleanPassword) {
        await prefs.setString(_currentEmailKey, cleanEmail);
        return true;
      }

      return false;
    }

    final legacyEmail = _cleanEmail(prefs.getString(_emailKey) ?? '');
    final legacyPassword = (prefs.getString(_passwordKey) ?? '').trim();

    if (legacyEmail == cleanEmail && legacyPassword == cleanPassword) {
      await prefs.setString(_currentEmailKey, cleanEmail);
      return true;
    }

    return false;
  }

  static Future<void> updateProfile({
    required String fullName,
    required String email,
    required String activityLevel,
    required String healthCondition,
    int? age,
    String? gender,
    double? height,
    double? weight,
    double? bmi,
    String? bmiStatus,
    int? dailyGoal,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final currentEmail = await _getCurrentEmail(prefs);
    final newEmail = _cleanEmail(email);
    final accounts = await _loadAccounts(prefs);

    final oldAccount = _accountByEmail(accounts, currentEmail) ?? {};
    final updatedAccount = <String, dynamic>{
      ...oldAccount,
      'fullName': fullName.trim(),
      'email': newEmail,
      'activityLevel': activityLevel.trim(),
      'healthCondition': healthCondition.trim(),
    };

    if (age != null) updatedAccount['age'] = age;
    if (gender != null) updatedAccount['gender'] = gender.trim();
    if (height != null) updatedAccount['height'] = height.toDouble();
    if (weight != null) updatedAccount['weight'] = weight.toDouble();
    if (bmi != null) updatedAccount['bmi'] = bmi.toDouble();
    if (bmiStatus != null) updatedAccount['bmiStatus'] = bmiStatus.trim();
    if (dailyGoal != null) updatedAccount['dailyGoal'] = dailyGoal;

    if (currentEmail != newEmail) {
      accounts.remove(currentEmail);
    }

    accounts[newEmail] = updatedAccount;

    await _saveAccounts(prefs, accounts);
    await prefs.setString(_currentEmailKey, newEmail);

    await prefs.setString(_fullNameKey, fullName.trim());
    await prefs.setString(_emailKey, newEmail);
    await prefs.setString(_activityLevelKey, activityLevel.trim());
    await prefs.setString(_healthConditionKey, healthCondition.trim());

    if (age != null) await prefs.setInt(_ageKey, age);
    if (gender != null) await prefs.setString(_genderKey, gender.trim());
    if (height != null) await prefs.setDouble(_heightKey, height.toDouble());
    if (weight != null) await prefs.setDouble(_weightKey, weight.toDouble());
    if (bmi != null) await prefs.setDouble(_bmiKey, bmi.toDouble());
    if (bmiStatus != null) await prefs.setString(_bmiStatusKey, bmiStatus.trim());
    if (dailyGoal != null) await prefs.setInt(_dailyGoalKey, dailyGoal);
  }

  static Future<void> updateFitnessGoals({
    required String goal,
    required double desiredWeight,
    required int dailyGoal,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final currentEmail = await _getCurrentEmail(prefs);
    final accounts = await _loadAccounts(prefs);

    final account = _accountByEmail(accounts, currentEmail) ?? {};
    account['goal'] = goal.trim();
    account['desiredWeight'] = desiredWeight.toDouble();
    account['dailyGoal'] = dailyGoal;

    if (currentEmail.isNotEmpty) {
      accounts[currentEmail] = account;
      await _saveAccounts(prefs, accounts);
    }

    await prefs.setString(_goalKey, goal.trim());
    await prefs.setDouble(_desiredWeightKey, desiredWeight.toDouble());
    await prefs.setInt(_dailyGoalKey, dailyGoal);
  }

  static Future<String> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    final account = await _currentAccount(prefs);

    if (account != null) {
      final value = _asString(account['fullName']);
      if (value.trim().isNotEmpty) return value;
    }

    return prefs.getString(_fullNameKey) ?? 'User';
  }

  static Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final account = await _currentAccount(prefs);

    if (account != null) {
      final value = _asString(account['email']);
      if (value.trim().isNotEmpty) return value;
    }

    return prefs.getString(_emailKey) ?? '';
  }

  static Future<int> getDailyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    final account = await _currentAccount(prefs);

    if (account != null) {
      final value = _asInt(account['dailyGoal']);
      if (value > 0) return value;
    }

    return prefs.getInt(_dailyGoalKey) ?? 0;
  }

  static Future<String> getGoal() async {
    final prefs = await SharedPreferences.getInstance();
    final account = await _currentAccount(prefs);

    if (account != null) {
      final value = _asString(account['goal']);
      if (value.trim().isNotEmpty) return value;
    }

    return prefs.getString(_goalKey) ?? '';
  }

  static Future<double> getDesiredWeight() async {
    final prefs = await SharedPreferences.getInstance();
    final account = await _currentAccount(prefs);

    if (account != null) {
      final value = _asDouble(account['desiredWeight']);
      if (value > 0) return value;
    }

    return _asDouble(prefs.get(_desiredWeightKey));
  }

  static Future<double> getBmi() async {
    final prefs = await SharedPreferences.getInstance();
    final account = await _currentAccount(prefs);

    if (account != null) {
      final value = _asDouble(account['bmi']);
      if (value > 0) return value;
    }

    return _asDouble(prefs.get(_bmiKey));
  }

  static Future<String> getBmiStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final account = await _currentAccount(prefs);

    if (account != null) {
      final value = _asString(account['bmiStatus']);
      if (value.trim().isNotEmpty) return value;
    }

    return prefs.getString(_bmiStatusKey) ?? '';
  }

  static Future<String> getActivityLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final account = await _currentAccount(prefs);

    if (account != null) {
      final value = _asString(account['activityLevel']);
      if (value.trim().isNotEmpty) return value;
    }

    return prefs.getString(_activityLevelKey) ?? '';
  }

  static Future<String> getHealthCondition() async {
    final prefs = await SharedPreferences.getInstance();
    final account = await _currentAccount(prefs);

    if (account != null) {
      final value = _asString(account['healthCondition']);
      if (value.trim().isNotEmpty) return value;
    }

    return prefs.getString(_healthConditionKey) ?? '';
  }

  static Future<int> getAge() async {
    final prefs = await SharedPreferences.getInstance();
    final account = await _currentAccount(prefs);

    if (account != null) {
      final value = _asInt(account['age']);
      if (value > 0) return value;
    }

    return prefs.getInt(_ageKey) ?? 0;
  }

  static Future<String> getGender() async {
    final prefs = await SharedPreferences.getInstance();
    final account = await _currentAccount(prefs);

    if (account != null) {
      final value = _asString(account['gender']);
      if (value.trim().isNotEmpty) return value;
    }

    return prefs.getString(_genderKey) ?? '';
  }

  static Future<double> getHeight() async {
    final prefs = await SharedPreferences.getInstance();
    final account = await _currentAccount(prefs);

    if (account != null) {
      final value = _asDouble(account['height']);
      if (value > 0) return value;
    }

    return _asDouble(prefs.get(_heightKey));
  }

  static Future<double> getWeight() async {
    final prefs = await SharedPreferences.getInstance();
    final account = await _currentAccount(prefs);

    if (account != null) {
      final value = _asDouble(account['weight']);
      if (value > 0) return value;
    }

    return _asDouble(prefs.get(_weightKey));
  }
}


