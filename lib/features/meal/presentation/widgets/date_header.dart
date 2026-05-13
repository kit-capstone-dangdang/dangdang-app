import 'package:flutter/material.dart';

class DateHeader extends StatelessWidget {
  final String date;

  const DateHeader({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          date,
          style: textTheme.bodySmall?.copyWith(
            color: Colors.grey,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
