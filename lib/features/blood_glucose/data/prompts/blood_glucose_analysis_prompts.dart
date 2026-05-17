class BloodGlucoseAnalysisPrompts {
  static String buildBloodGlucoseAnalysisPrompt({
    required String bloodGlucoseRecordsJson,
    required String rangeLabel,
    required String timeFilter,
    required String diabetesType,
  }) {
    return '''
혈당 기록을 분석하는 건강 코치야.
JSON만 반환해.

당뇨 유형: $diabetesType
조회 기간: $rangeLabel
조회 시간대: $timeFilter

혈당 기록:
$bloodGlucoseRecordsJson

형식:
{
  "patterns": [],
  "recommendations": [],
  "reportText": ""
}

규칙:
- 한국어 사용
- 당뇨 유형과 필터 조건 고려
- 기록만 기반으로 분석
- 의료 진단·약물 조언 금지
- 혈당 변화 패턴 중심
- patterns/recommendations 각 1~3개
- reportText는 2~3문장
- 키는 patterns, recommendations, reportText만 사용
- JSON만 반환
''';
  }
}
