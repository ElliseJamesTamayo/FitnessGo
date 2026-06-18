import 'package:flutter/material.dart';

import '../../../../core/storage/api_session_store.dart';
import '../../../../data/local_auth_store.dart';
import '../../../../data/local_calorie_store.dart';
import '../../../../data/local_user_store.dart';
import '../../data/auth_api.dart';import '../../../../models/signup_data.dart';
import '../../../../screens/dashboard_screen.dart';
import 'steps/account_credentials_step.dart';
import 'steps/activity_level_step.dart';
import 'steps/goal_step.dart';
import 'steps/health_condition_step.dart';
import 'steps/personal_info_step.dart';
import 'steps/profile_photo_step.dart';
import 'steps/signup_result_step.dart';
import 'steps/terms_step.dart';
import '../../../../data/user_session.dart';

class SignupFlowScreen extends StatefulWidget {
  static const routeName = '/signup';

  const SignupFlowScreen({super.key});

  @override
  State<SignupFlowScreen> createState() => _SignupFlowScreenState();
}

class _SignupFlowScreenState extends State<SignupFlowScreen> {
  final SignupData data = SignupData();

  int currentStep = 0;
  bool isCreatingAccount = false;
  static const totalSteps = 8;

  void nextStep() {
    if (currentStep < totalSteps - 1) {
      setState(() {
        currentStep++;
      });
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }


  String currentHealthAnswer() {
    return data.hasHealthCondition.trim().isEmpty
        ? 'No'
        : data.hasHealthCondition.trim();
  }

  String primaryHealthCondition() {
    if (currentHealthAnswer() != 'Yes') return 'None';

    if (data.otherHealthCondition.trim().isNotEmpty) {
      return data.otherHealthCondition.trim();
    }

    if (data.healthConditions.isNotEmpty) {
      return data.healthConditions.first.trim();
    }

    return 'None';
  }

  double responseDouble(
    Map<String, dynamic> source,
    List<String> keys,
    double fallback,
  ) {
    for (final key in keys) {
      final value = source[key];
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return fallback;
  }

  int responseInt(
    Map<String, dynamic> source,
    List<String> keys,
    int fallback,
  ) {
    for (final key in keys) {
      final value = source[key];
      if (value is int) return value;
      if (value is num) return value.round();
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) return parsed.round();
      }
    }
    return fallback;
  }

  String responseString(
    Map<String, dynamic> source,
    List<String> keys,
    String fallback,
  ) {
    for (final key in keys) {
      final value = source[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return fallback;
  }

  Future<void> registerAndContinue() async {
    if (isCreatingAccount) return;

    setState(() {
      isCreatingAccount = true;
    });

    try {
      final hasCondition = currentHealthAnswer();
      final conditionText = primaryHealthCondition();

      final registerResult = await AuthApi.register(
        username: data.username,
        email: data.email,
        password: data.password,
        fullname: data.fullName,
        age: data.age ?? 0,
        gender: data.gender,
        height: data.height ?? 0,
        weight: data.weight ?? 0,
        goal: data.goal,
        activityLevel: data.activityLevel,
        desiredWeight: data.desiredWeight,
        hasHealthConditions: hasCondition,
        whatHealthConditions: hasCondition == 'Yes' ? conditionText : null,
      );

      if (registerResult['success'] != true) {
        if (!mounted) return;

        setState(() {
          isCreatingAccount = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              registerResult['message']?.toString() ??
                  'Signup failed. Please try again.',
            ),
          ),
        );
        return;
      }

      final userId = int.tryParse(
            '${registerResult['UserId'] ?? registerResult['userId'] ?? registerResult['user_id'] ?? 0}',
          ) ??
          0;

      if (userId <= 0) {
        if (!mounted) return;

        setState(() {
          isCreatingAccount = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signup failed: User ID was not returned by API.'),
          ),
        );
        return;
      }

      final backendDailyGoal = responseInt(
        registerResult,
        ['DailyNetGoal', 'dailyNetGoal', 'daily_goal', 'dailyGoal'],
        data.dailyCalorieGoal,
      );

      final backendBmi = responseDouble(
        registerResult,
        ['BMI', 'bmi'],
        data.bmi,
      );

      final backendBmiStatus = responseString(
        registerResult,
        ['BMIStatus', 'bmiStatus', 'bmi_status'],
        data.bmiStatus,
      );

      data.userId = userId;
      data.backendDailyCalorieGoal = backendDailyGoal;
      data.backendBmi = backendBmi;
      data.backendBmiStatus = backendBmiStatus;

      await ApiSessionStore.saveUserId(userId);

      await LocalAuthStore.saveSignup(
        fullName: data.fullName,
        email: data.email,
        password: data.password,
        dailyGoal: backendDailyGoal,
        goal: data.goal,
        desiredWeight: data.desiredWeight ?? 0,
        bmi: backendBmi,
        bmiStatus: backendBmiStatus,
        activityLevel: data.activityLevel,
        healthCondition: conditionText,
        age: data.age ?? 0,
        gender: data.gender,
        height: data.height ?? 0,
        weight: data.weight ?? 0,
      );

      LocalUserStore.setFullName(data.fullName);
      LocalCalorieStore.setDailyGoal(backendDailyGoal);
      LocalCalorieStore.clear();

      if (!mounted) return;

      setState(() {
        isCreatingAccount = false;
        currentStep++;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully. You can add a photo next.'),
          backgroundColor: Color(0xFF008000),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isCreatingAccount = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signup failed: $error'),
        ),
      );
    }
  }
  void finishSignup() async {
  await UserSession.saveUser(
    name: data.fullName,
    age: data.age ?? 0,
    gender: data.gender,
    weight: data.weight ?? 0,
    height: data.height ?? 0,
    goal: data.goal,
    calorieGoal: data.displayDailyCalorieGoal,
  );

  Navigator.pushReplacementNamed(context, DashboardScreen.routeName);
}


  Widget buildCurrentStep() {
    return switch (currentStep) {
      0 => TermsStep(
          data: data,
          onAccept: nextStep,
          onDecline: () => Navigator.pop(context),
        ),
      1 => PersonalInfoStep(
          data: data,
          onNext: nextStep,
          onBack: previousStep,
        ),
      2 => ActivityLevelStep(
          data: data,
          onNext: nextStep,
          onBack: previousStep,
        ),
      3 => GoalStep(
          data: data,
          onNext: nextStep,
          onBack: previousStep,
        ),
      4 => HealthConditionStep(
          data: data,
          onNext: nextStep,
          onBack: previousStep,
        ),
      5 => AccountCredentialsStep(
          data: data,
          onNext: registerAndContinue,
          onBack: previousStep,
        ),
      6 => ProfilePhotoStep(
          userId: data.userId,
          onNext: nextStep,
          onBack: previousStep,
        ),
      _ => SignupResultStep(
          data: data,
          onFinish: finishSignup,
          onBack: previousStep,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6E6E6),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: KeyedSubtree(
            key: ValueKey(currentStep),
            child: buildCurrentStep(),
          ),
        ),
      ),
    );
  }
}





