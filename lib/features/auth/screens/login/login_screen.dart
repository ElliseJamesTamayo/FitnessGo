import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/api_session_store.dart';
import '../../../../data/local_auth_store.dart';
import '../../../../data/local_calorie_store.dart';
import '../../../../data/local_user_store.dart';
import '../../../../screens/dashboard_screen.dart';
import '../../../../widgets/app_button.dart';
import '../../../../widgets/app_logo.dart';
import '../../../../widgets/app_text_field.dart';
import '../../data/auth_api.dart';
import '../signup/signup_flow_screen.dart';
class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String nameFromUsername(String username) {
    final cleanedName = username.trim().replaceAll(RegExp(r'[._-]+'), ' ');

    if (cleanedName.isEmpty) return 'User';

    return cleanedName
        .split(RegExp(r'\s+'))
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  Future<void> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your username and password.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final loginResult = await AuthApi.login(
      username: username,
      password: password,
    );

    if (!mounted) return;

    if (loginResult['success'] != true) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ApiClient.asString(loginResult['message']).isEmpty
                ? 'Invalid username or password.'
                : ApiClient.asString(loginResult['message']),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userId = ApiClient.asInt(loginResult['UserId']);

    if (userId <= 0) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login succeeded, but UserId was missing.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await ApiSessionStore.saveUserId(userId);

    final profile = await AuthApi.getProfile(userId);

    if (!mounted) return;

    if (profile['UserId'] == null) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login succeeded, but profile could not be loaded.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final fullName = ApiClient.asString(profile['Fullname']);
    final email = ApiClient.asString(profile['Email']);
    final dailyGoal = ApiClient.asInt(profile['DailyNetGoal']);

    await LocalAuthStore.saveSignup(
      fullName: fullName.isEmpty ? nameFromUsername(username) : fullName,
      email: email.isEmpty ? username : email,
      password: password,
      dailyGoal: dailyGoal,
      goal: ApiClient.asString(profile['Goal']),
      desiredWeight: ApiClient.asDouble(profile['DesiredWeight']),
      bmi: ApiClient.asDouble(profile['BMI']),
      bmiStatus: ApiClient.asString(profile['BMIStatus']),
      activityLevel: ApiClient.asString(profile['ActivityLevel']),
      healthCondition:
          ApiClient.asString(profile['WhatHealthConditions']).isEmpty
              ? ApiClient.asString(profile['HasHealthConditions'])
              : ApiClient.asString(profile['WhatHealthConditions']),
      age: ApiClient.asInt(profile['Age']),
      gender: ApiClient.asString(profile['Gender']),
      height: ApiClient.asDouble(profile['Height']),
      weight: ApiClient.asDouble(profile['Weight']),
    );

    LocalUserStore.setFullName(
      fullName.isEmpty ? nameFromUsername(username) : fullName,
    );

    if (dailyGoal > 0) {
      LocalCalorieStore.setDailyGoal(dailyGoal);
    } else if (LocalCalorieStore.dailyGoal == 0) {
      LocalCalorieStore.setDailyGoal(2000);
    }

    LocalCalorieStore.clear();

    setState(() {
      isLoading = false;
    });

    Navigator.pushReplacementNamed(
      context,
      DashboardScreen.routeName,
    );
  }

  Widget fieldLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 7),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6E6E6),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              children: [
                const AppLogo(size: 110),
                const SizedBox(height: 12),
                const Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Log in to continue your fitness journey.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      fieldLabel('Username'),
                      AppTextField(
                        controller: usernameController,
                        label: 'Enter your username',
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 16),
                      fieldLabel('Password'),
                      AppTextField(
                        controller: passwordController,
                        label: 'Enter your password',
                        icon: Icons.lock,
                        isPassword: true,
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Color(0xFF008000),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          text: isLoading ? 'Logging in...' : 'Login',
                          onPressed: () {
                            if (!isLoading) {
                              login();
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'No account yet?',
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                SignupFlowScreen.routeName,
                              );
                            },
                            child: const Text(
                              'Create Account',
                              style: TextStyle(
                                color: Color(0xFF008000),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}





