import 'dart:convert';

import 'package:dangdang/core/ai/gemini/gemini_client.dart';
import 'package:dangdang/features/meal/data/datasources/meal_ai_service.dart';
import 'package:dangdang/features/meal/domain/entities/meal_record.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeMealGeminiClient extends Fake implements GeminiClient {
  String response = '{"patterns":["식사 패턴"],"recommendations":["식단 추천"]}';
  String? prompt;
  bool fail = false;

  @override
  Future<String> generateText(String prompt) async {
    this.prompt = prompt;
    if (fail) throw StateError('Gemini unavailable');
    return response;
  }

  @override
  Map<String, dynamic> decodeJsonObject(String text) =>
      jsonDecode(text) as Map<String, dynamic>;
}

void main() {
  late FakeMealGeminiClient client;
  late MealAiService service;
  final record = MealRecord(
    id: '', uid: '', dateTime: DateTime(2026, 9, 7), mealType: '점심',
    foods: [], imageUrl: '', aiComment: '기존 코멘트', totalNutrition: {},
  );

  setUp(() {
    client = FakeMealGeminiClient();
    service = MealAiService(client: client);
  });

  Future<MealHabitAnalysisResult> analyze() => service.analyzeMealHabits(
    records: [record], scopeLabel: '전체', diabetesType: '2형',
  );

  test('parses existing analysis fields without rating and requests no rating', () async {
    final result = await analyze();
    expect(result.patterns, ['식사 패턴']);
    expect(result.recommendations, ['식단 추천']);
    expect(client.prompt, isNot(contains('rating')));
    expect(client.prompt, contains('키는 patterns, recommendations만 사용'));
    expect(client.prompt, contains('기존 코멘트'));
  });

  test('empty records return empty analysis without calling Gemini', () async {
    final result = await service.analyzeMealHabits(
      records: [], scopeLabel: '전체', diabetesType: '2형',
    );
    expect(result.patterns, isEmpty);
    expect(result.recommendations, isEmpty);
    expect(client.prompt, isNull);
  });

  test('missing analysis lists retain existing empty defaults', () async {
    client.response = '{}';
    final result = await analyze();
    expect(result.patterns, isEmpty);
    expect(result.recommendations, isEmpty);
  });

  test('Gemini errors propagate to the existing error UI', () async {
    client.fail = true;
    await expectLater(analyze(), throwsStateError);
  });

  test('malformed Gemini JSON propagates as an error', () async {
    client.response = 'invalid JSON';
    await expectLater(analyze(), throwsFormatException);
  });
}
