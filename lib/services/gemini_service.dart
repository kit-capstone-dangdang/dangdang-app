import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import '../models/food_item.dart';
import '../models/meal_record.dart';
import '../utils/nutrition_utils.dart';

class GeminiService {
  final GenerativeModel _model;

  GeminiService()
    : _model = GenerativeModel(
        model: 'gemini-3.1-flash-lite-preview',
        apiKey: const String.fromEnvironment('GEMINI_API_KEY'),
      );

  Future<MealRecord> analyzeFoodImage({
    required XFile image,
    required String mealType,
    required DateTime dateTime,
    String id = '',
  }) async {
    final imageBytes = await image.readAsBytes();

    const prompt = '''
음식 사진을 분석해서 JSON만 반환해줘. 설명, 마크다운, 코드블록은 넣지 마.

형식:
{
  "foods": [
    {
      "name": "음식명",
      "amountLabel": "1그릇",
      "servingCount": 1.0,
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
- carbohydrate, protein, fat, sugar는 g 기준 숫자만 넣어줘.
- aiComment는 당뇨 관리 관점에서 2문장으로 짧게 작성해줘.
- JSON 외 다른 텍스트는 절대 넣지 마.
''';

    final content = [
      Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
    ];

    final response = await _model.generateContent(content);
    final text = response.text;

    if (text == null || text.trim().isEmpty) {
      throw Exception('분석 결과를 가져오지 못했습니다.');
    }

    final cleanedText = text
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    final result = jsonDecode(cleanedText) as Map<String, dynamic>;
    final foodsJson = (result['foods'] as List<dynamic>? ?? []);

    final foods = foodsJson.map((food) {
      final item = food as Map<String, dynamic>;

      final carbohydrate = parseDouble(item['carbohydrate']);
      final protein = parseDouble(item['protein']);
      final fat = parseDouble(item['fat']);
      final sugar = parseDouble(item['sugar']);

      return FoodItem(
        name: item['name'] ?? '',
        amountLabel: item['amountLabel'] ?? '',
        servingCount: parseDouble(item['servingCount'], defaultValue: 1.0),
        calories: calculateCalories(
          carbohydrate: carbohydrate,
          protein: protein,
          fat: fat,
        ),
        carbohydrate: carbohydrate,
        protein: protein,
        fat: fat,
        sugar: sugar,
      );
    }).toList();

    final totalNutrition = MealRecord.totalNutritionFromFoods(foods);

    return MealRecord(
      id: id,
      dateTime: dateTime,
      mealType: mealType,
      foods: foods,
      imageUrl: '',
      aiComment: result['aiComment'] ?? '',
      totalNutrition: totalNutrition,
    );
  }

  Future<List<FoodItem>> refineMultipleFoodsInfo(List<String> foodNames) async {
    if (foodNames.isEmpty) return [];

    final namesText = foodNames.join(', ');
    const prompt = '''
제공된 음식 리스트의 각 항목에 대한 영양 정보를 JSON 배열로 반환해줘. 설명이나 코드블록 없이 JSON만 반환해.

형식:
[
  {
    "name": "입력받은 음식명",
    "amountLabel": "1그릇",
    "servingCount": 1.0,
    "carbohydrate": 0,
    "protein": 0,
    "fat": 0,
    "sugar": 0
  }
]

규칙:
- 입력받은 음식 리스트의 순서를 반드시 유지해줘.
- servingCount는 1.0으로 고정해줘.
- carbohydrate, protein, fat, sugar는 g 기준 숫자만 넣어줘.
''';

    final content = [Content.text('음식 리스트: $namesText\n\n$prompt')];
    final response = await _model.generateContent(content);
    final text = response.text;

    if (text == null || text.trim().isEmpty) throw Exception('분석 실패');

    final cleanedText = text
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
    final List<dynamic> decoded = jsonDecode(cleanedText);

    return decoded.map((item) {
      final mapItem = item as Map<String, dynamic>;
      final carbohydrate = parseDouble(mapItem['carbohydrate']);
      final protein = parseDouble(mapItem['protein']);
      final fat = parseDouble(mapItem['fat']);
      final sugar = parseDouble(mapItem['sugar']);

      return FoodItem(
        name: mapItem['name'] ?? '',
        amountLabel: mapItem['amountLabel'] ?? '1인분',
        servingCount: 1.0,
        calories: calculateCalories(
          carbohydrate: carbohydrate,
          protein: protein,
          fat: fat,
        ),
        carbohydrate: carbohydrate,
        protein: protein,
        fat: fat,
        sugar: sugar,
      );
    }).toList();
  }
}
