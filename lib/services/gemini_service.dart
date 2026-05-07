import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

import '../model/food_item.dart';
import '../model/meal_record.dart';

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
- servingCount는 숫자만 넣어줘. 예: 0.5, 1.0, 1.5
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

      final carbohydrate = _toDouble(item['carbohydrate']);
      final protein = _toDouble(item['protein']);
      final fat = _toDouble(item['fat']);
      final sugar = _toDouble(item['sugar']);

      return FoodItem(
        name: item['name'] ?? '',
        amountLabel: item['amountLabel'] ?? '',
        servingCount: _toDouble(item['servingCount'], defaultValue: 1.0),
        calories: _calculateCalories(
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

    final totalNutrition = _calculateTotalNutrition(foods);

    return MealRecord(
      id: id,
      dateTime: dateTime,
      mealType: mealType,
      foods: foods,
      aiComment: result['aiComment'] ?? '',
      totalNutrition: totalNutrition,
    );
  }

  Map<String, double> _calculateTotalNutrition(List<FoodItem> foods) {
    double calories = 0;
    double carbohydrate = 0;
    double protein = 0;
    double fat = 0;
    double sugar = 0;

    for (final food in foods) {
      calories += food.calories;
      carbohydrate += food.carbohydrate;
      protein += food.protein;
      fat += food.fat;
      sugar += food.sugar;
    }

    return {
      'calories': calories,
      'carbohydrate': carbohydrate,
      'protein': protein,
      'fat': fat,
      'sugar': sugar,
    };
  }

  double _calculateCalories({
    required double carbohydrate,
    required double protein,
    required double fat,
  }) {
    return (carbohydrate * 4) + (protein * 4) + (fat * 9);
  }

  double _toDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
}
