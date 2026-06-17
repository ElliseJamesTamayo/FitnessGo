import 'package:flutter/material.dart';

import '../../../../../models/signup_data.dart';
import '../../../../../widgets/app_button.dart';
import '../../../../../widgets/app_logo.dart';
import '../../../../../widgets/app_text_field.dart';

class HealthConditionStep extends StatefulWidget {
  final SignupData data;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const HealthConditionStep({
    super.key,
    required this.data,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<HealthConditionStep> createState() => _HealthConditionStepState();
}

class _HealthConditionStepState extends State<HealthConditionStep> {
  final otherController = TextEditingController();

  String answer = 'No';
  final Set<String> conditions = {};

  @override
  void initState() {
    super.initState();

    answer = widget.data.hasHealthCondition.isEmpty
        ? 'No'
        : widget.data.hasHealthCondition;

    conditions.addAll(widget.data.healthConditions);
    otherController.text = widget.data.otherHealthCondition;
  }

  @override
  void dispose() {
    otherController.dispose();
    super.dispose();
  }

  void toggleCondition(String condition) {
    setState(() {
      if (conditions.contains(condition)) {
        conditions.remove(condition);
      } else {
        conditions.add(condition);
      }
    });
  }

  void validateAndContinue() {
    widget.data.hasHealthCondition = answer;

    if (answer == 'No') {
      widget.data.healthConditions = [];
      widget.data.otherHealthCondition = '';
      widget.onNext();
      return;
    }

    if (conditions.isEmpty) {
      showError('Please select at least one health condition.');
      return;
    }

    if (conditions.contains('Others') && otherController.text.trim().isEmpty) {
      showError('Please specify your health condition.');
      return;
    }

    widget.data.healthConditions = conditions.toList();
    widget.data.otherHealthCondition = otherController.text.trim();

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
            'Step 4/6',
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

  Widget yesNoButton(String label) {
    final selected = answer == label;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            answer = label;

            if (label == 'No') {
              conditions.clear();
              otherController.clear();
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 56,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF008000) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF008000),
              width: 1.6,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF008000),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget conditionCard({
    required String title,
    required IconData icon,
  }) {
    final selected = conditions.contains(title);

    return GestureDetector(
      onTap: () => toggleCondition(title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF008000) : const Color(0xFFF9FFF9),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFF008000),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor:
                  selected ? Colors.white : const Color(0xFFE8F5E9),
              child: Icon(
                icon,
                color: const Color(0xFF008000),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle,
                color: Colors.white,
              ),
          ],
        ),
      ),
    );
  }

  Widget noConditionInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FFF9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFB7E4B7),
          width: 1.4,
        ),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 34,
            backgroundColor: Color(0xFFE8F5E9),
            child: Icon(
              Icons.health_and_safety,
              color: Color(0xFF008000),
              size: 34,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No health condition selected',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose Yes only if you have a condition that may affect your exercise recommendations.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.4,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Color(0xFF008000),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'You can continue if you do not have any listed condition.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
    final showConditionOptions = answer == 'Yes';
    final showOtherField = conditions.contains('Others');

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
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
                    'Do you have any health conditions?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'This helps us recommend safer fitness activities.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      yesNoButton('Yes'),
                      const SizedBox(width: 12),
                      yesNoButton('No'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  if (showConditionOptions) ...[
                    fieldLabel('Select health condition'),

                    conditionCard(
                      title: 'Heart Disease',
                      icon: Icons.favorite,
                    ),

                    const SizedBox(height: 13),

                    conditionCard(
                      title: 'Asthma',
                      icon: Icons.air,
                    ),

                    const SizedBox(height: 13),

                    conditionCard(
                      title: 'Others',
                      icon: Icons.medical_information,
                    ),

                    if (showOtherField) ...[
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: otherController,
                        label: 'Please specify',
                        icon: Icons.edit_note,
                      ),
                    ],
                  ] else ...[
                    noConditionInfoCard(),
                  ],

                  const SizedBox(height: 28),

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





