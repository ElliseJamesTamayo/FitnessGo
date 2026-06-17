import 'package:flutter/material.dart';

import '../../../../../models/signup_data.dart';
import '../../../../../widgets/app_button.dart';
import '../../../../../widgets/app_logo.dart';

class ActivityLevelStep extends StatefulWidget {
  final SignupData data;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const ActivityLevelStep({
    super.key,
    required this.data,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<ActivityLevelStep> createState() => _ActivityLevelStepState();
}

class _ActivityLevelStepState extends State<ActivityLevelStep> {
  String selected = '';

  @override
  void initState() {
    super.initState();
    selected = widget.data.activityLevel;
  }

  void validateAndContinue() {
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an activity level.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    widget.data.activityLevel = selected;
    widget.onNext();
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
            'Step 2/6',
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

  Widget activityCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = selected == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selected = title;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(17),
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
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
                  'What is your activity level?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Choose the option that best describes your usual movement.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 24),

                activityCard(
                  title: 'Not Very Active',
                  subtitle: 'Mostly sitting or light daily movement.',
                  icon: Icons.event_seat,
                ),

                const SizedBox(height: 13),

                activityCard(
                  title: 'Lightly Active',
                  subtitle: 'Light walking or occasional exercise.',
                  icon: Icons.directions_walk,
                ),

                const SizedBox(height: 13),

                activityCard(
                  title: 'Active',
                  subtitle: 'Regular movement or exercise weekly.',
                  icon: Icons.directions_run,
                ),

                const SizedBox(height: 13),

                activityCard(
                  title: 'Very Active',
                  subtitle: 'Frequent intense exercise or active lifestyle.',
                  icon: Icons.fitness_center,
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
    );
  }
}




