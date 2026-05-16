import 'dart:convert';
import 'package:dangdang/core/ai/gemini/gemini_client.dart';
import 'package:dangdang/features/blood_glucose/domain/entities/blood_glucose_record.dart';
import 'package:dangdang/features/blood_glucose/data/prompts/blood_glucose_analysis_prompts.dart';
import 'package:dangdang/features/blood_glucose/domain/entities/blood_glucose_analysis_result.dart'; // 경로에 맞게 수정해주세요

class BloodGlucoseAIService {
  final GeminiClient _geminiClient;

  BloodGlucoseAIService({GeminiClient? client})
    : _geminiClient = client ?? GeminiClient();

  Future<BloodGlucoseAnalysisResult> analyzeBloodSugarHabits({
    required List<BloodGlucoseRecord> records,
    required String rangeLabel,
    required String timeFilter,
  }) async {
    try {
      if (records.isEmpty) {
        return const BloodGlucoseAnalysisResult(
          patterns: ['선택하신 조건에 해당하는 혈당 데이터가 없습니다.'],
          recommendations: ['먼저 혈당을 기록하고 AI 분석을 받아보세요!'],
          reportText: '',
        );
      }

      final List<Map<String, dynamic>> recordMaps = records
          .map(
            (e) => {
              'dateTime': e.dateTime.toString(),
              'bloodSugar': e.bloodSugar,
              'mealState': e.mealState,
            },
          )
          .toList();
      final String recordsJson = jsonEncode(recordMaps);

      final prompt =
          BloodGlucoseAnalysisPrompts.buildBloodGlucoseAnalysisPrompt(
            bloodGlucoseRecordsJson: recordsJson,
            rangeLabel: rangeLabel,
            timeFilter: timeFilter,
          );

      final response = await _geminiClient.generateText(prompt);

      if (response.isEmpty) {
        throw Exception('응답이 비어있습니다.');
      }

      final responseData = _geminiClient.decodeJsonObject(response);

      return BloodGlucoseAnalysisResult.fromJson(responseData);
    } catch (e) {
      return const BloodGlucoseAnalysisResult(
        patterns: ['분석 중 오류가 발생했습니다.'],
        recommendations: ['잠시 후 다시 시도해주세요.'],
        reportText: '',
      );
    }
  }
}
