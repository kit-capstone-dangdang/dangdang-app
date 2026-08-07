import 'package:dangdang/core/utils/parsers/value_parser.dart';

class BloodGlucoseAnalysisResult {
  final List<String> patterns;
  final List<String> recommendations;
  final String reportText;
  final double rating;

  const BloodGlucoseAnalysisResult({
    required this.patterns,
    required this.recommendations,
    required this.reportText,
    required this.rating,
  });

  factory BloodGlucoseAnalysisResult.fromJson(Map<String, dynamic> json) {
    return BloodGlucoseAnalysisResult(
      patterns: List<String>.from(json['patterns'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      reportText: json['reportText']?.toString() ?? '',
      rating: _normalizeRating(json['rating']),
    );
  }

  static double _normalizeRating(dynamic value) {
    final parsed = parseDouble(value, defaultValue: 0.5);
    final clamped = parsed.clamp(0.5, 5.0).toDouble();
    return (clamped * 2).round() / 2;
  }
}
