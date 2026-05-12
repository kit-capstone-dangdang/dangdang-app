const mealAnalysisPrompt = '''
음식 사진을 분석해서 JSON만 반환해줘. 설명, 마크다운, 코드블록은 넣지 마.

형식:
{
  "foods": [
    {
      "name": "음식명",
      "amountLabel": "1그릇",
      "servingCount": 1.0,
      "calories": 0,
      "carbohydrate": 0,
      "protein": 0,
      "fat": 0,
      "sugar": 0
    }
  ],
  "aiComment": "식단 분석 코멘트"
}

규칙:
- 사진 속 음식이 여러 개면 foods에 각각 넣어줘.
- amountLabel은 "1그릇", "1접시", "1잔", "1.0인분"처럼 사람이 읽기 쉬운 문자열로 작성해줘.
- servingCount는 숫자만 넣어줘.
- calories는 kcal 기준 숫자만 넣어줘.
- calories는 carbohydrate, protein, fat 값으로 직접 계산하지 말고 사진 속 음식의 종류, 양, 제품 특성을 고려해서 추정해줘.
- 가공식품, 무설탕 제품, 제로 제품은 일반 칼로리 공식만 적용하지 말고 제품 특성을 반영해줘.
- carbohydrate, protein, fat, sugar는 g 기준 숫자만 넣어줘.
- aiComment는 당뇨 관리 관점에서 2문장으로 짧게 작성해줘.
- JSON 외 다른 텍스트는 절대 넣지 마.
''';
