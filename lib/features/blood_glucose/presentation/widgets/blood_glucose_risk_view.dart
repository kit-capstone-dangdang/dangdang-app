import 'package:flutter/material.dart';

import '../../domain/services/blood_glucose_risk_calculator.dart';

class BloodGlucoseRiskView extends StatelessWidget {
  final BloodGlucoseRiskLevel? lowRiskLevel;
  final BloodGlucoseRiskLevel? highRiskLevel;

  const BloodGlucoseRiskView({
    super.key,
    required this.lowRiskLevel,
    required this.highRiskLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.health_and_safety_outlined,
              color: Color(0xFF2F69FE),
            ),
            const SizedBox(width: 8),
            Text(
              '혈당 위험',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111827),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F8FF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE3ECFC), width: 1.5),
          ),
          child: Column(
            children: [
              _riskRow(context, '저혈당 위험', lowRiskLevel),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: Color(0xFFE3ECFC)),
              ),
              _riskRow(context, '고혈당 위험', highRiskLevel),
            ],
          ),
        ),
      ],
    );
  }

  Widget _riskRow(
    BuildContext context,
    String title,
    BloodGlucoseRiskLevel? level,
  ) {
    final (label, color) = switch (level) {
      BloodGlucoseRiskLevel.low => ('낮음', const Color(0xFF34A853)),
      BloodGlucoseRiskLevel.moderate => ('보통', const Color(0xFFEF6C00)),
      BloodGlucoseRiskLevel.high => ('높음', const Color(0xFFE53935)),
      null => ('평가 불가', Colors.grey),
    };
    return Row(
      children: [
        Expanded(child: Text(title)),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
