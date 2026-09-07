import 'dart:math' as math;

import '../entities/blood_glucose_record.dart';

enum BloodGlucoseRiskLevel { low, moderate, high }

class BloodGlucoseRiskAssessment {
  final double? lbgi;
  final double? hbgi;
  final BloodGlucoseRiskLevel? riskLevel;
  final double? targetRate;
  final double? finalRating;

  const BloodGlucoseRiskAssessment({
    required this.lbgi,
    required this.hbgi,
    required this.riskLevel,
    required this.targetRate,
    required this.finalRating,
  });
}

BloodGlucoseRiskAssessment calculateBloodGlucoseRisk(
  List<BloodGlucoseRecord> records,
) {
  var validCount = 0;
  var targetCount = 0;
  var metTargetCount = 0;
  var lowRiskSum = 0.0;
  var highRiskSum = 0.0;

  for (final record in records) {
    final bg = record.bloodSugar;
    // Invalid measurements cannot contribute to either risk or target rate.
    if (bg <= 0) continue;
    validCount++;
    final f = 1.509 * (math.pow(math.log(bg), 1.084) - 5.381);
    final risk = 10 * math.pow(f, 2);
    if (f < 0) lowRiskSum += risk;
    if (f > 0) highRiskSum += risk;

    final bool? meetsTarget = switch (record.mealState) {
      '공복' || '식전' => bg >= 80 && bg <= 130,
      '식후' => bg < 180,
      // Bedtime and unknown states have no target rule.
      _ => null,
    };
    if (meetsTarget != null) {
      targetCount++;
      if (meetsTarget) metTargetCount++;
    }
  }

  // Both indices use ALL valid measurements, including the opposite risk side.
  final lbgi = validCount == 0 ? null : lowRiskSum / validCount;
  final hbgi = validCount == 0 ? null : highRiskSum / validCount;
  final BloodGlucoseRiskLevel? riskLevel;
  if (lbgi == null || hbgi == null) {
    riskLevel = null;
  } else if (lbgi > 5 || hbgi > 9) {
    riskLevel = BloodGlucoseRiskLevel.high;
  } else if (lbgi > 2.5 || hbgi > 4.5) {
    riskLevel = BloodGlucoseRiskLevel.moderate;
  } else {
    riskLevel = BloodGlucoseRiskLevel.low;
  }

  final targetRate = targetCount == 0 ? null : metTargetCount / targetCount;
  // Service-specific star display caps, not clinical rating thresholds.
  final cap = switch (riskLevel) {
    BloodGlucoseRiskLevel.low => 5.0,
    BloodGlucoseRiskLevel.moderate => 3.5,
    BloodGlucoseRiskLevel.high => 2.0,
    null => null,
  };
  final baseRating = targetRate == null
      ? null
      : ((targetRate * 10).round() / 2).clamp(0.5, 5.0).toDouble();

  return BloodGlucoseRiskAssessment(
    lbgi: lbgi,
    hbgi: hbgi,
    riskLevel: riskLevel,
    targetRate: targetRate,
    finalRating: baseRating == null || cap == null
        ? null
        : math.min(baseRating, cap),
  );
}
