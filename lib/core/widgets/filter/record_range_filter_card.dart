import 'package:flutter/material.dart';

class RecordRangeFilterCard extends StatelessWidget {
  final String label;
  final bool isExpanded;
  final VoidCallback onTap;

  const RecordRangeFilterCard({
    super.key,
    required this.label,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF3F4F7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: Color(0xFF5A46F5),
                size: 24,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF26324B),
                  ),
                ),
              ),
              Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.chevron_right_rounded,
                color: const Color(0xFF9AA1B4),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
