import 'package:flutter/material.dart';

class CustomIcon extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final VoidCallback? onPressed;

  const CustomIcon({
    super.key,
    required this.icon,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.white,
    this.size = 50,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.grey.withOpacity(0.2),
          highlightColor: Colors.grey.withOpacity(0.1),
          onTap: onPressed,
          child: Icon(icon, color: iconColor),
        ),
      ),
    );
  }
}
