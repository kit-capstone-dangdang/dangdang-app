String buildFoodRefinePrompt(List<String> foodNames) {
  final namesText = foodNames.join(', ');

  return '''
음식 리스트:
$namesText

각 음식의 영양 정보를 JSON 배열로 반환해.

형식:
[
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
]

규칙:
- 입력 순서 유지
- servingCount는 1.0 고정
- 모든 영양값은 숫자만 사용
- 음식 종류와 일반적인 1인분 기준으로 추정
- JSON만 반환
''';
}
