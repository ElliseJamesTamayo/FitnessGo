import 'package:flutter/material.dart';

import '../../../../../data/local_auth_store.dart';
import '../../../../../core/storage/api_session_store.dart';
import '../../../../../data/local_calorie_store.dart';
import '../../../../../data/local_user_store.dart';
import '../../../../../models/signup_data.dart';
import '../../../../../widgets/app_button.dart';
import '../../../data/auth_api.dart';

class SignupResultStep extends StatelessWidget {
  final SignupData data;
  final VoidCallback onFinish;
  final VoidCallback onBack;

  const SignupResultStep({
    super.key,
    required this.data,
    required this.onFinish,
    required this.onBack,
  });

  Widget resultCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FFF7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF008000),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFE8F5E9),
            child: Icon(
              icon,
              color: const Color(0xFF008000),
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 23,
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bmi = data.bmi;
    final bmiText = bmi == 0 ? '--' : bmi.toStringAsFixed(1);
    final bmiStatus = data.bmiStatus;
    final calories = data.dailyCalorieGoal.round();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
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
                const Text(
                  'Your Fitness Summary',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Here is your starting fitness profile based on your details.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 26),
                resultCard(
                  title: 'Body Mass Index',
                  value: bmiText,
                  subtitle: bmiStatus,
                  icon: Icons.monitor_heart,
                ),
                const SizedBox(height: 16),
                resultCard(
                  title: 'Daily Calorie Goal',
                  value: '$calories kcal',
                  subtitle: 'Recommended daily intake estimate',
                  icon: Icons.local_fire_department,
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      summaryRow('Name', data.fullName),
                      summaryRow('Goal', data.goal),
                      summaryRow('Activity Level', data.activityLevel),
                      summaryRow(
                        'Current Weight',
                        data.weight == null ? '--' : '${data.weight} kg',
                      ),
                      summaryRow(
                        'Desired Weight',
                        data.desiredWeight == null
                            ? '--'
                            : '${data.desiredWeight} kg',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Back',
                        outlined: true,
                        onPressed: onBack,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        text: 'Dashboard',
                        onPressed: () async {
                          final selectedConditions = <String>[
                            ...data.healthConditions,
                          ];

                          if (data.otherHealthCondition.trim().isNotEmpty) {
                            selectedConditions.add(
                              data.otherHealthCondition.trim(),
                            );
                          }

                          final healthConditionText =
                              data.hasHealthCondition == 'Yes' &&
                                      selectedConditions.isNotEmpty
                                  ? selectedConditions.join(', ')
                                  : 'None';

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
                            hasHealthConditions:
                                data.hasHealthCondition.isEmpty
                                    ? 'No'
                                    : data.hasHealthCondition,
                            whatHealthConditions: healthConditionText,
                          );

                          if (registerResult['success'] != true) {
                            if (!context.mounted) return;

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
                                '${registerResult['UserId'] ?? registerResult['userId'] ?? 0}',
                              ) ??
                              0;

                          if (userId > 0) {
                            await ApiSessionStore.saveUserId(userId);
                          }

                          await LocalAuthStore.saveSignup(
                            fullName: data.fullName,
                            email: data.email,
                            password: data.password,
                            dailyGoal: data.dailyCalorieGoal,
                            goal: data.goal,
                            desiredWeight: data.desiredWeight ?? 0,
                            bmi: data.bmi,
                            bmiStatus: data.bmiStatus,
                            activityLevel: data.activityLevel,
                            healthCondition: healthConditionText,
                            age: data.age ?? 0,
                            gender: data.gender,
                            height: data.height ?? 0,
                            weight: data.weight ?? 0,
                          );

                          LocalUserStore.setFullName(data.fullName);
                          LocalCalorieStore.setDailyGoal(data.dailyCalorieGoal);
                          LocalCalorieStore.clear();

                          if (!context.mounted) return;
                          onFinish();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}







