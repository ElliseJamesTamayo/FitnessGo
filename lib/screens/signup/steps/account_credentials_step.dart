import 'package:flutter/material.dart';

import '../../../models/signup_data.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_logo.dart';
import '../../../widgets/app_text_field.dart';

class AccountCredentialsStep extends StatefulWidget {
  final SignupData data;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const AccountCredentialsStep({
    super.key,
    required this.data,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<AccountCredentialsStep> createState() => _AccountCredentialsStepState();
}

class _AccountCredentialsStepState extends State<AccountCredentialsStep> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    usernameController.text = widget.data.username;
    emailController.text = widget.data.email;
    passwordController.text = widget.data.password;
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void validateAndContinue() {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showError('Please complete all fields.');
      return;
    }

    if (!email.endsWith('@iskolarngbayan.pup.edu.ph')) {
      showError('Email must be a valid PUP student email.');
      return;
    }

    if (password.length < 6) {
      showError('Password must be at least 6 characters.');
      return;
    }

    if (password != confirmPassword) {
      showError('Passwords do not match.');
      return;
    }

    widget.data.username = username;
    widget.data.email = email;
    widget.data.password = password;

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
            'Step 5/6',
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

  Widget infoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FFF9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFB7E4B7),
          width: 1.2,
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.verified_user,
            color: Color(0xFF008000),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Use your official PUP student email for account verification.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

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
                    'Create Your Profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Set up your login details for FitnessGo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 20),

                  infoCard(),

                  const SizedBox(height: 20),

                  fieldLabel('Username'),

                  AppTextField(
                    controller: usernameController,
                    label: 'Choose a username',
                    icon: Icons.account_circle,
                  ),

                  const SizedBox(height: 15),

                  fieldLabel('PUP Email'),

                  AppTextField(
                    controller: emailController,
                    label: 'example@iskolarngbayan.pup.edu.ph',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 15),

                  fieldLabel('Password'),

                  AppTextField(
                    controller: passwordController,
                    label: 'Enter password',
                    icon: Icons.lock,
                    isPassword: true,
                  ),

                  const SizedBox(height: 15),

                  fieldLabel('Confirm Password'),

                  AppTextField(
                    controller: confirmPasswordController,
                    label: 'Re-enter password',
                    icon: Icons.lock_outline,
                    isPassword: true,
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
                          text: 'Sign Up',
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

