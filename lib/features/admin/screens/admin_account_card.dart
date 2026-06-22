import 'package:flutter/material.dart';

class AdminAccountCard extends StatelessWidget {
  const AdminAccountCard({
    super.key,
    required this.name,
    required this.email,
    this.subtitle,
    this.trailing,
    this.leadingIcon = Icons.person_rounded,
  });

  final String name;
  final String email;
  final String? subtitle;
  final Widget? trailing;
  final IconData leadingIcon;

  static const Color green = Color(0xFF00A000);
  static const Color darkGreen = Color(0xFF008000);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2ECDD)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: green.withOpacity(0.10), shape: BoxShape.circle),
            child: Icon(leadingIcon, color: darkGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Unnamed User' : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.black87),
                ),
                const SizedBox(height: 3),
                Text(
                  email.isEmpty ? 'No email' : email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
                ),
                if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: darkGreen, fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}
