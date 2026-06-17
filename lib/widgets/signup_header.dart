import 'package:flutter/material.dart';

import 'app_logo.dart';

class SignupHeader extends StatelessWidget {
  const SignupHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 8),
      child: Row(
        children: [
          AppLogo(size: 72),
          SizedBox(width: 8),
          Text(
            'Fitness Go',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
