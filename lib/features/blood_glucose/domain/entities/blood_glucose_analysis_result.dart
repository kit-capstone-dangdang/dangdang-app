class BloodGlucoseAnalysisResult {
  final List<String> patterns;
  final List<String> recommendations;
  final String reportText;

  const BloodGlucoseAnalysisResult({
    required this.patterns,
    required this.recommendations,
    required this.reportText,
  });

  factory BloodGlucoseAnalysisResult.fromJson(Map<String, dynamic> json) {
    return BloodGlucoseAnalysisResult(
      patterns: List<String>.from(json['patterns'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      reportText: json['reportText']?.toString() ?? '',
    );
  }
}
