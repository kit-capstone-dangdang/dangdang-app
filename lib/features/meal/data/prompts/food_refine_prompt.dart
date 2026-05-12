String buildFoodRefinePrompt(List<String> foodNames) {
  final namesText = foodNames.join(', ');

  return '''
음식 리스트: $namesText

제공된 음식 리스트의 각 항목에 대한 영양 정보를 JSON 배열로 반환해줘. 설명이나 코드블록 없이 JSON만 반환해.

형식:
[
  {
    "name": "입력받은 음식명",
    "amountLabel": "1그릇",
    "servingCount": 1.0,
    "calories": 0,
    "carbohydrate": 0,
    "protein": 0,
    "fat": 0,
    "sugar": 0
  }
]

규칙:
- 입력받은 음식 리스트의 순서를 반드시 유지해줘.
- servingCount는 1.0으로 고정해줘.
- calories는 kcal 기준 숫자만 넣어줘.
- calories는 carbohydrate, protein, fat 값으로 직접 계산하지 말고 음식명, 제품명, 일반적인 1인분 기준을 고려해서 추정해줘.
- 가공식품, 무설탕 제품, 제로 제품은 일반 칼로리 공식만 적용하지 말고 제품 특성을 반영해줘.
- carbohydrate, protein, fat, sugar는 g 기준 숫자만 넣어줘.
''';
}
