class BloodGlucoseAnalysisResult {
  final List<String> patterns;
  final List<String> recommendations;
  final String reportText;
  final double? rating;

  const BloodGlucoseAnalysisResult({
    required this.patterns,
    required this.recommendations,
    required this.reportText,
    required this.rating,
  });

  factory BloodGlucoseAnalysisResult.fromJson(
    Map<String, dynamic> json, {
    required double? rating,
  }) {
    return BloodGlucoseAnalysisResult(
      patterns: List<String>.from(json['patterns'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      reportText: json['reportText']?.toString() ?? '',
      rating: rating,
    );
  }
}
