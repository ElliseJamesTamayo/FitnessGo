import 'package:flutter/material.dart';

import '../../../../../models/signup_data.dart';
import '../../../../../widgets/app_button.dart';
import '../../../../../widgets/app_logo.dart';
import '../../../../../widgets/app_text_field.dart';

class PersonalInfoStep extends StatefulWidget {
  final SignupData data;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const PersonalInfoStep({
    super.key,
    required this.data,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<PersonalInfoStep> createState() => _PersonalInfoStepState();
}

class _PersonalInfoStepState extends State<PersonalInfoStep> {
  final fullNameController = TextEditingController();
  final ageController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();

  String gender = '';

  @override
  void initState() {
    super.initState();

    fullNameController.text = widget.data.fullName;
    ageController.text = widget.data.age?.toString() ?? '';
    weightController.text = widget.data.weight?.toString() ?? '';
    heightController.text = widget.data.height?.toString() ?? '';
    gender = widget.data.gender;
  }

  @override
  void dispose() {
    fullNameController.dispose();
    ageController.dispose();
    weightController.dispose();
    heightController.dispose();
    super.dispose();
  }

  void validateAndContinue() {
    final fullName = fullNameController.text.trim();
    final ageText = ageController.text.trim();
    final weightText = weightController.text.trim();
    final heightText = heightController.text.trim();

    if (fullName.isEmpty ||
        ageText.isEmpty ||
        weightText.isEmpty ||
        heightText.isEmpty ||
        gender.isEmpty) {
      showError('Please complete all fields.');
      return;
    }

    final age = int.tryParse(ageText);
    final weight = double.tryParse(weightText);
    final height = double.tryParse(heightText);

    if (age == null || age <= 0) {
      showError('Please enter a valid age.');
      return;
    }

    if (weight == null || weight <= 0) {
      showError('Please enter a valid weight.');
      return;
    }

    if (height == null || height <= 0) {
      showError('Please enter a valid height.');
      return;
    }

    widget.data.fullName = fullName;
    widget.data.age = age;
    widget.data.weight = weight;
    widget.data.height = height;
    widget.data.gender = gender;

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

  Widget genderChoice({
    required String label,
    required IconData icon,
  }) {
    final selected = gender == label;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            gender = label;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 54,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF008000) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF008000),
              width: 1.6,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.22),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected ? Colors.white : const Color(0xFF008000),
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF008000),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
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
            'Step 1/6',
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
                    'Tell us more about yourself',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'This helps us personalize your fitness journey.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 24),

                  fieldLabel('Full Name'),

                  AppTextField(
                    controller: fullNameController,
                    label: 'Enter your full name',
                    icon: Icons.person,
                  ),

                  const SizedBox(height: 16),

                  fieldLabel('Age'),

                  AppTextField(
                    controller: ageController,
                    label: 'Enter your age',
                    icon: Icons.cake,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  fieldLabel('Gender'),

                  Row(
                    children: [
                      genderChoice(
                        label: 'Female',
                        icon: Icons.female,
                      ),
                      const SizedBox(width: 12),
                      genderChoice(
                        label: 'Male',
                        icon: Icons.male,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            fieldLabel('Weight'),
                            AppTextField(
                              controller: weightController,
                              label: 'kg',
                              icon: Icons.monitor_weight,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          children: [
                            fieldLabel('Height'),
                            AppTextField(
                              controller: heightController,
                              label: 'cm',
                              icon: Icons.height,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Already have an account?',
                      style: TextStyle(
                        color: Color(0xFF008000),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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




