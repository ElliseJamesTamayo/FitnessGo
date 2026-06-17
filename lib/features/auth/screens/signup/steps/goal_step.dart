import 'package:flutter/material.dart';

import '../../../../../models/signup_data.dart';
import '../../../../../widgets/app_button.dart';
import '../../../../../widgets/app_logo.dart';
import '../../../../../widgets/app_text_field.dart';

class GoalStep extends StatefulWidget {
  final SignupData data;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const GoalStep({
    super.key,
    required this.data,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<GoalStep> createState() => _GoalStepState();
}

class _GoalStepState extends State<GoalStep> {
  final desiredWeightController = TextEditingController();
  String selectedGoal = '';

  @override
  void initState() {
    super.initState();
    selectedGoal = widget.data.goal;
    desiredWeightController.text = widget.data.desiredWeight?.toString() ?? '';
  }

  @override
  void dispose() {
    desiredWeightController.dispose();
    super.dispose();
  }

  void validateAndContinue() {
    final desiredText = desiredWeightController.text.trim();

    if (selectedGoal.isEmpty) {
      showError('Please select your goal.');
      return;
    }

    if (desiredText.isEmpty) {
      showError('Desired weight is required.');
      return;
    }

    final desiredWeight = double.tryParse(desiredText);
    final currentWeight = widget.data.weight;

    if (desiredWeight == null || desiredWeight <= 0) {
      showError('Please enter a valid desired weight.');
      return;
    }

    if (currentWeight != null) {
      if (selectedGoal == 'Lose weight' && desiredWeight >= currentWeight) {
        showError('Desired weight must be lower than your current weight.');
        return;
      }

      if ((selectedGoal == 'Gain weight' || selectedGoal == 'Gain muscles') &&
          desiredWeight <= currentWeight) {
        showError('Desired weight must be higher than your current weight.');
        return;
      }

      if (selectedGoal == 'Keep fit' && desiredWeight != currentWeight) {
        showError('Desired weight must be the same as your current weight.');
        return;
      }
    }

    widget.data.goal = selectedGoal;
    widget.data.desiredWeight = desiredWeight;

    widget.onNext();
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget compactHeader() {
    return Row(
      children: [
        AppLogo(size: 46),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Fitness Go',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Step 3/6',
            style: TextStyle(
              color: Color(0xFF008000),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget goalCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = selectedGoal == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGoal = title;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF008000) : const Color(0xFFF9FFF9),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFF008000),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor:
                  isSelected ? Colors.white : const Color(0xFFE8F5E9),
              child: Icon(
                icon,
                color: const Color(0xFF008000),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.black54,
                      fontSize: 13,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.white,
              ),
          ],
        ),
      ),
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
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          children: [
            compactHeader(),

            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: screenHeight * 0.76,
              ),
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
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
                    'What is your goal?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Choose your main fitness target.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 24),

                  goalCard(
                    title: 'Lose weight',
                    subtitle: 'Reduce body weight through calorie control.',
                    icon: Icons.trending_down,
                  ),

                  const SizedBox(height: 13),

                  goalCard(
                    title: 'Gain weight',
                    subtitle: 'Increase body weight in a healthy way.',
                    icon: Icons.trending_up,
                  ),

                  const SizedBox(height: 13),

                  goalCard(
                    title: 'Keep fit',
                    subtitle: 'Maintain your current weight and stay active.',
                    icon: Icons.favorite,
                  ),

                  const SizedBox(height: 13),

                  goalCard(
                    title: 'Gain muscles',
                    subtitle: 'Build strength and improve muscle mass.',
                    icon: Icons.fitness_center,
                  ),

                  const SizedBox(height: 20),

                  fieldLabel('Desired Weight'),

                  AppTextField(
                    controller: desiredWeightController,
                    label: 'kg',
                    icon: Icons.monitor_weight,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),

                  const SizedBox(height: 26),

                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Back',
                          outlined: true,
                          onPressed: widget.onBack,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          text: 'Continue',
                          onPressed: validateAndContinue,
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
    );
  }
}




