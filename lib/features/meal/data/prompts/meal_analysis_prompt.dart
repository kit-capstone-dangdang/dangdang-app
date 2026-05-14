const mealAnalysisPrompt = '''
음식 사진을 보고 JSON만 반환해.
설명, 마크다운, 코드블록 금지.

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
  "aiComment": "짧은 한국어 코멘트"
}

규칙:
- 음식이 여러 개면 모두 foods에 넣어.
- amountLabel은 "1그릇", "1접시", "1잔", "1인분"처럼 써.
- servingCount, calories, carbohydrate, protein, fat, sugar는 숫자만.
- 영양값은 음식 종류와 보이는 양 기준으로 추정해.
- 가공식품, 국물, 소스, 디저트, 음료 특성 반영해.
- aiComment는 혈당 관리 관점의 한국어 2문장.
- JSON만 반환.
''';

String buildMealHabitAnalysisPrompt({
  required String scopeLabel,
  required String mealRecordsJson,
}) {
  return '''
사용자의 실제 식단 기록을 분석하는 영양 코치야.
JSON만 반환해. 설명, 마크다운, 코드블록 금지.

분석 범위:
$scopeLabel

식단 기록 JSON:
$mealRecordsJson

형식:
{
  "patterns": [
    "한국어 문장",
    "한국어 문장"
  ],
  "recommendations": [
    "한국어 문장",
    "한국어 문장"
  ]
}

규칙:
- 모든 문장은 한국어.
- 주어진 기록만 보고 분석해.
- 식사 시간, 반복 메뉴, 탄단지 균형, 당류 많은 식사, 야식, 규칙성을 중심으로 봐.
- 필요하면 실제 음식명이나 식사 유형을 언급해.
- patterns는 3~5개 관찰.
- recommendations는 3~5개 실천 제안.
- 각 항목은 1~2문장 이내.
- 키는 patterns, recommendations만 사용.
''';
}
