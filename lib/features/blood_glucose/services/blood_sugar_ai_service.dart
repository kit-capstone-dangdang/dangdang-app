import 'dart:convert';
import 'package:dangdang/core/ai/gemini/gemini_client.dart';
import '../data/prompts/blood_sugar_analysis_prompts.dart';

class BloodSugarAIService {
  final GeminiClient _geminiClient;

  BloodSugarAIService(this._geminiClient);

  Future<String> getBloodSugarReportText(String recordsJson) async {
    try {
      if (recordsJson.isEmpty || recordsJson == '[]') {
        return "아직 기록된 혈당 데이터가 없어요. 첫 혈당을 기록하고 AI 분석을 받아보세요!";
      }

      final prompt = BloodSugarAnalysisPrompts.buildBloodSugarAnalysisPrompt(
        bloodSugarRecordsJson: recordsJson,
      );

      final response = await _geminiClient.generateText(prompt);

      if (response.isEmpty) {
        return "리포트를 불러오는 데 실패했습니다.";
      }

      // 혹시 모를 마크다운 찌꺼기 제거 (Gemini가 코드블록을 넣을 경우 대비)
      final cleanJsonString = response
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      // JSON 파싱
      final Map<String, dynamic> responseData = jsonDecode(cleanJsonString);

      // AIReportCard에 들어갈 reportText만 반환
      return responseData['reportText'] ?? "분석 결과를 해석할 수 없습니다.";
    } catch (e) {
      return "분석 중 오류가 발생했습니다: $e";
    }
  }
}
