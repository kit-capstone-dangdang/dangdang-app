import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color backgroundColor;
  final bool showShadow;
  final VoidCallback? onTap;
  final BoxBorder? border;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.borderRadius = 30.0,
    this.backgroundColor = Colors.white,
    this.showShadow = true,
    this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: border,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    );
  }
}
