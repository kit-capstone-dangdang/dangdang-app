import 'package:flutter/material.dart';

class ProfileSelectChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;
  final bool showBorderWhenUnselected;

  const ProfileSelectChip({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
    this.selectedColor = const Color(0xFF4F63F6),
    this.showBorderWhenUnselected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected
                ? selectedColor.withOpacity(0.2)
                : showBorderWhenUnselected
                ? const Color(0xFFE5E7EB)
                : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: selected ? selectedColor : const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }
}
