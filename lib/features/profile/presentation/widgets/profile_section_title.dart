import 'package:flutter/material.dart';

class ProfileSectionTitle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;

  const ProfileSectionTitle({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 26),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}
