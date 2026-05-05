import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

class GeminiService {
  final GenerativeModel _model;

  GeminiService()
    : _model = GenerativeModel(
        model: 'gemini-3.1-flash-lite-preview',
        apiKey: const String.fromEnvironment('GEMINI_API_KEY'),
      );

  Future<Map<String, dynamic>> analyzeFoodImage(XFile image) async {
    final imageBytes = await image.readAsBytes();

    const prompt = '''
음식 사진을 분석해서 JSON만 반환해줘. 설명, 마크다운, 코드블록은 넣지 마.

형식:
{
  "foods": [
    {
      "name": "음식명",
      "amount": "1그릇",
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
- carbohydrate, protein, fat, sugar는 g 기준 숫자만 넣어줘.
- 음식 양은 기본적으로 1인분 기준으로 추정해줘.
- 밥류는 1공기, 국물류는 1그릇, 반찬류는 1접시, 음료는 1잔처럼 써줘.
- aiComment는 당뇨 관리 관점에서 2문장으로 짧게 작성해줘.
''';

    final content = [
      Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
    ];

    final response = await _model.generateContent(content);
    final text = response.text;

    if (text == null || text.isEmpty) {
      throw Exception('분석 결과를 가져오지 못했습니다.');
    }

    final cleanedText = text
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    final result = jsonDecode(cleanedText) as Map<String, dynamic>;
    final foods = result['foods'] as List<dynamic>;

    for (final food in foods) {
      final item = food as Map<String, dynamic>;

      final carbohydrate = _toInt(item['carbohydrate']);
      final protein = _toInt(item['protein']);
      final fat = _toInt(item['fat']);

      item['calories'] = _calculateCalories(
        carbohydrate: carbohydrate,
        protein: protein,
        fat: fat,
      );
    }

    result['totalNutrition'] = _calculateTotalNutrition(foods);

    return result;
  }

  Map<String, int> _calculateTotalNutrition(List<dynamic> foods) {
    int calories = 0;
    int carbohydrate = 0;
    int protein = 0;
    int fat = 0;
    int sugar = 0;

    for (final food in foods) {
      final item = food as Map<String, dynamic>;

      calories += _toInt(item['calories']);
      carbohydrate += _toInt(item['carbohydrate']);
      protein += _toInt(item['protein']);
      fat += _toInt(item['fat']);
      sugar += _toInt(item['sugar']);
    }

    return {
      'calories': calories,
      'carbohydrate': carbohydrate,
      'protein': protein,
      'fat': fat,
      'sugar': sugar,
    };
  }

  int _calculateCalories({
    required int carbohydrate,
    required int protein,
    required int fat,
  }) {
    return (carbohydrate * 4) + (protein * 4) + (fat * 9);
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
