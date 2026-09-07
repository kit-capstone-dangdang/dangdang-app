import '../services/blood_glucose_risk_calculator.dart';

class BloodGlucoseAnalysisResult {
  final List<String> patterns;
  final List<String> recommendations;
  final String reportText;
  final double? rating;
  final BloodGlucoseRiskLevel? lowRiskLevel;
  final BloodGlucoseRiskLevel? highRiskLevel;

  const BloodGlucoseAnalysisResult({
    required this.patterns,
    required this.recommendations,
    required this.reportText,
    required this.rating,
    required this.lowRiskLevel,
    required this.highRiskLevel,
  });

  factory BloodGlucoseAnalysisResult.fromJson(
    Map<String, dynamic> json, {
    required double? rating,
    required BloodGlucoseRiskLevel? lowRiskLevel,
    required BloodGlucoseRiskLevel? highRiskLevel,
  }) {
    return BloodGlucoseAnalysisResult(
      patterns: List<String>.from(json['patterns'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      reportText: json['reportText']?.toString() ?? '',
      rating: rating,
      lowRiskLevel: lowRiskLevel,
      highRiskLevel: highRiskLevel,
    );
  }
}
