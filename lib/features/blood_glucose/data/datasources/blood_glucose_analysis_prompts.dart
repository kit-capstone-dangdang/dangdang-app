import 'package:dangdang/features/blood_glucose/domain/services/blood_glucose_risk_calculator.dart';

class BloodGlucoseAnalysisPrompts {
  static String buildBloodGlucoseAnalysisPrompt({
    required String bloodGlucoseRecordsJson,
    required String rangeLabel,
    required String timeFilter,
    required String diabetesType,
    required BloodGlucoseRiskAssessment assessment,
  }) {
    return '''
혈당 기록을 분석하는 건강 코치야.
JSON만 반환해.

당뇨 유형: $diabetesType
조회 기간: $rangeLabel
조회 시간대: $timeFilter

혈당 기록:
$bloodGlucoseRecordsJson

앱 계산 결과 (선택된 기록 기준):
LBGI: ${assessment.lbgi}
HBGI: ${assessment.hbgi}
위험등급: ${assessment.riskLevel?.name ?? '평가 불가'}
목표 충족률 (0~1): ${assessment.targetRate}
finalRating: ${assessment.finalRating}

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
- 앱 계산 결과를 참고해 설명만 생성하고 지표나 별점을 생성·재계산·변경하지 말 것
- BG <= 0은 유효하지 않은 기록이며 분석에서 제외
- 목표는 공복/식전 80~130 mg/dL, 식후 180 mg/dL 미만이며 취침전 및 알 수 없는 상태는 목표 충족률에서 제외
- 취침전도 양수 혈당이면 LBGI/HBGI 계산에는 포함됨
- null은 평가할 수 없다는 뜻이며 0점이나 낮은 위험으로 해석하지 말 것
- 별점 상한 5.0/3.5/2.0은 서비스 자체 표시 규칙이며 임상 기준으로 설명하지 말 것
- patterns/recommendations 각 1~3개
- reportText는 2~3문장
- 키는 patterns, recommendations, reportText만 사용
- JSON만 반환
''';
  }
}
