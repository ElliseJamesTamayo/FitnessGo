import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool outlined;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.outlined = false,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(24);

    if (outlined) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF008000),
            side: const BorderSide(
              color: Color(0xFF008000),
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius,
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF008000),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}