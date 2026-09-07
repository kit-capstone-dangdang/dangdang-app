import 'package:dangdang/core/ai/gemini/gemini_client.dart';
import 'package:dangdang/features/blood_glucose/data/datasources/blood_glucose_ai_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'blood_glucose_risk_calculator_test.dart' show record;

class FakeGeminiClient extends Fake implements GeminiClient {
  String? prompt;
  bool fail = false;

  @override
  Future<String> generateText(String prompt) async {
    this.prompt = prompt;
    if (fail) throw Exception('offline');
    return 'response';
  }

  @override
  Map<String, dynamic> decodeJsonObject(String text) => {
    'patterns': ['패턴'],
    'recommendations': ['추천'],
    'reportText': '설명',
    'rating': 0.5,
  };
}

void main() {
  test(
    'uses local rating and sends metrics while requesting only text fields',
    () async {
      final client = FakeGeminiClient();
      final result = await BloodGlucoseAIService(client: client)
          .analyzeBloodSugarHabits(
            records: [record(100)],
            rangeLabel: '전체',
            timeFilter: '전체',
            diabetesType: '2형',
          );
      expect(result.rating, 5);
      expect(result.reportText, '설명');
      expect(client.prompt, contains('LBGI: 0.482'));
      expect(client.prompt, contains('HBGI: 0.0'));
      expect(client.prompt, contains('위험등급: low'));
      expect(client.prompt, contains('목표 충족률 (0~1): 1.0'));
      expect(client.prompt, contains('finalRating: 5.0'));
      expect(client.prompt, isNot(contains('"rating"')));
    },
  );

  test('AI failure preserves locally calculated rating', () async {
    final client = FakeGeminiClient()..fail = true;
    final result = await BloodGlucoseAIService(client: client)
        .analyzeBloodSugarHabits(
          records: [record(80)],
          rangeLabel: '전체',
          timeFilter: '전체',
          diabetesType: '2형',
        );
    expect(result.rating, 3.5);
    expect(result.patterns.single, contains('오류'));
  });

  test('empty data skips Gemini and returns no rating', () async {
    final client = FakeGeminiClient();
    final result = await BloodGlucoseAIService(client: client)
        .analyzeBloodSugarHabits(
          records: [],
          rangeLabel: '전체',
          timeFilter: '전체',
          diabetesType: '2형',
        );
    expect(client.prompt, isNull);
    expect(result.rating, isNull);
  });

  test('bedtime-only data cannot acquire a rating from Gemini', () async {
    final client = FakeGeminiClient();
    final result = await BloodGlucoseAIService(client: client)
        .analyzeBloodSugarHabits(
          records: [record(100, '취침전')],
          rangeLabel: '전체',
          timeFilter: '취침전',
          diabetesType: '2형',
        );
    expect(result.rating, isNull);
    expect(client.prompt, contains('finalRating: null'));
  });
}
