import 'package:flutter/material.dart';

import '../widgets/app_button.dart';
import '../widgets/app_logo.dart';
import 'role_screen.dart';

class WelcomeScreen extends StatelessWidget {
  static const routeName = '/';

  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6E6E6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 28, 26, 28),
          child: Column(
            children: [
              const Spacer(),

              Container(
                width: 185,
                height: 185,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: AppLogo(size: 130),
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Fitness Go',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Your smart fitness companion for tracking goals, progress, and healthier habits.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.black54,
                ),
              ),

              const Spacer(),

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
                    const Text(
                      'Start your fitness journey today.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        text: 'Get Started',
                        onPressed: () {
                          Navigator.pushNamed(context, RoleScreen.routeName);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
