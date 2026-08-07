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
- servingCount는 기본적으로 1.0 고정, 단 음료는 amountLabel의 ml 숫자와 같은 값을 사용해
- 모든 영양값은 숫자만 사용
- 음식 종류와 일반적인 1인분 기준으로 추정
- 음료는 반드시 ml 단위 amountLabel을 사용해. 예: 콜라 500ml, 우유 200ml, 주스 350ml
- 음료는 1인분, 1팩, 1개, 1잔 같은 개수 단위로 반환하지 마
- JSON만 반환
''';
}
