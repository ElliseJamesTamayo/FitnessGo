import 'package:flutter/material.dart';

class OptionButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final String? subtitle;

  const OptionButton({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
    this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final green = const Color(0xFF008000);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color: selected ? green : const Color(0xFF66CC66),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? green : const Color(0xFF66CC66),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


