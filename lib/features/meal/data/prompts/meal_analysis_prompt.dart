const mealAnalysisPrompt = '''
음식 사진을 보고 JSON만 반환해.

형식:
{
  "foods": [
    {
      "name": "음식명",
      "amountLabel": "1인분",
      "servingCount": 1.0,
      "calories": 0,
      "carbohydrate": 0,
      "protein": 0,
      "fat": 0,
      "sugar": 0
    }
  ],
  "aiComment": "혈당 관리 관점의 한국어 2문장"
}

규칙:
- 음식이 여러 개면 모두 foods에 넣어
- 도시락, 세트, 정식, 한 접시 음식도 보이는 구성요소를 각각 분리해
- 예: 돈가스 도시락이면 돈가스, 밥, 샐러드, 반찬을 따로 넣어
- 단, 구성요소가 잘 안 보이면 대표 음식명으로 작성해
- amountLabel은 "1그릇", "1접시", "1잔", "1인분"처럼 작성
- 영양값은 보이는 음식과 양 기준으로 숫자만 추정
- 가공식품, 국물, 소스, 디저트, 음료 특성 반영
- JSON만 반환
''';

String buildMealHabitAnalysisPrompt({
  required String scopeLabel,
  required String mealRecordsJson,
  required String diabetesType,
}) {
  return '''
식단 기록을 분석하는 영양 코치야.
JSON만 반환해.

당뇨 유형: $diabetesType
분석 범위: $scopeLabel

식단 기록:
$mealRecordsJson

형식:
{
  "patterns": [],
  "recommendations": []
}

규칙:
- 한국어 사용
- 당뇨 유형 고려
- 기록만 기반으로 분석
- 의료 진단·약물 조언 금지
- 식사 시간, 탄단지, 당류, 야식, 규칙성 중심
- patterns/recommendations 각 3~5개
- 키는 patterns, recommendations만 사용
- JSON만 반환
''';
}
