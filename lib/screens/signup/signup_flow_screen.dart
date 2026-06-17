import 'package:flutter/material.dart';

import '../../models/signup_data.dart';
import '../dashboard_screen.dart';
import 'steps/account_credentials_step.dart';
import 'steps/activity_level_step.dart';
import 'steps/goal_step.dart';
import 'steps/health_condition_step.dart';
import 'steps/personal_info_step.dart';
import 'steps/profile_photo_step.dart';
import 'steps/signup_result_step.dart';
import 'steps/terms_step.dart';
import '../../data/user_session.dart';

class SignupFlowScreen extends StatefulWidget {
  static const routeName = '/signup';

  const SignupFlowScreen({super.key});

  @override
  State<SignupFlowScreen> createState() => _SignupFlowScreenState();
}

class _SignupFlowScreenState extends State<SignupFlowScreen> {
  final SignupData data = SignupData();

  int currentStep = 0;
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

  void finishSignup() async {
  await UserSession.saveUser(
    name: data.fullName,
    age: data.age ?? 0,
    gender: data.gender,
    weight: data.weight ?? 0,
    height: data.height ?? 0,
    goal: data.goal,
    calorieGoal: data.dailyCalorieGoal,
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
          onNext: nextStep,
          onBack: previousStep,
        ),
      6 => ProfilePhotoStep(
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
