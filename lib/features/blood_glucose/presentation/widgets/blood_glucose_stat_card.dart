// 통계카드위젯
import 'package:flutter/material.dart';

class BloodGlucoseStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subText;
  final Color subTextColor;
  final Color valueColor;

  const BloodGlucoseStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subText,
    required this.subTextColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(subText, style: TextStyle(color: subTextColor, fontSize: 12)),
        ],
      ),
    );
  }
}
