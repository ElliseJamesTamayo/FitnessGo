import 'package:flutter/material.dart';

import '../../../models/signup_data.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_logo.dart';

class TermsStep extends StatefulWidget {
  final SignupData data;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const TermsStep({
    super.key,
    required this.data,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  State<TermsStep> createState() => _TermsStepState();
}

class _TermsStepState extends State<TermsStep> {
  bool accepted = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const AppLogo(size: 90),
          const SizedBox(height: 10),
          const Text(
            'Terms & Conditions',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF008000),
              fontSize: 29,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Before creating an account, please read and accept our Terms and Conditions.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const SingleChildScrollView(
                child: Text(
                  'By using FitnessGo, you agree to:\n\n'
                  '1. Conditions of Use\n'
                  'By accessing this application, you confirm that you have read, understood, and agree to comply with these Terms and Conditions.\n\n'
                  '2. User Responsibilities\n'
                  'You agree to use the system responsibly and only for its intended purpose.\n\n'
                  '3. Content and Conduct\n'
                  'You must not post harmful or inappropriate content. Content may be reviewed.\n\n'
                  '4. Account Management\n'
                  'Repeated violations may result in account deactivation.\n\n'
                  '5. Data Privacy & Security\n'
                  'Your personal information is collected and used only for system functionality, account management, and service improvement.',
                  style: TextStyle(fontSize: 14, height: 1.4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            value: accepted,
            activeColor: const Color(0xFF008000),
            onChanged: (value) {
              setState(() {
                accepted = value ?? false;
              });
            },
            title: const Text('I accept the Terms & Conditions'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Decline',
                  outlined: true,
                  onPressed: widget.onDecline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  text: 'Accept',
                  onPressed: accepted
                      ? () {
                          widget.data.acceptedTerms = true;
                          widget.onAccept();
                        }
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please accept the Terms & Conditions first.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
