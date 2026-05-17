import 'package:flutter/material.dart';

class SecurityPrivacyMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onTap;

  const SecurityPrivacyMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.backgroundColor,
    required this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(width: 28),
            Expanded(
              child: Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: iconColor.withOpacity(0.35),
              size: 34,
            ),
          ],
        ),
      ),
    );
  }
}
