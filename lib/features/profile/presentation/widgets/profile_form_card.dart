import 'package:flutter/material.dart';

class ProfileFormCard extends StatelessWidget {
  final TextEditingController controller;
  final IconData? icon;
  final IconData? suffixIcon;
  final String? suffixText;
  final TextInputType? keyboardType;

  const ProfileFormCard({
    super.key,
    required this.controller,
    this.icon,
    this.suffixIcon,
    this.suffixText,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textAlignVertical: TextAlignVertical.center,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: const Color(0xFF111827),
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          prefixIcon: icon == null
              ? null
              : Icon(icon, color: const Color(0xFF9CA3AF), size: 30),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 66,
            minHeight: 78,
          ),
          suffixIcon: suffixIcon == null
              ? null
              : Icon(suffixIcon, color: Colors.black, size: 24),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 58,
            minHeight: 78,
          ),
          suffix: suffixText == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    suffixText!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
          contentPadding: EdgeInsets.only(
            left: icon == null ? 28 : 0,
            right: suffixText == null ? 22 : 12,
          ),
        ),
      ),
    );
  }
}
