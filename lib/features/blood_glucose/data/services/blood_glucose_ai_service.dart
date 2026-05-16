import 'package:dangdang/core/ai/gemini/gemini_client.dart';
import 'package:dangdang/features/blood_glucose/data/prompts/blood_glucose_analysis_prompts.dart';

class BloodGlucoseAIService {
  final GeminiClient _geminiClient;

  BloodGlucoseAIService({GeminiClient? client})
    : _geminiClient = client ?? GeminiClient();

  Future<String> getBloodGlucoseReportText(String recordsJson) async {
    try {
      if (recordsJson.isEmpty || recordsJson == '[]') {
        return '아직 기록된 혈당 데이터가 없어요. 첫 혈당을 기록하고 AI 분석을 받아보세요!';
      }

      final prompt =
          BloodGlucoseAnalysisPrompts.buildBloodGlucoseAnalysisPrompt(
            bloodGlucoseRecordsJson: recordsJson,
          );

      final response = await _geminiClient.generateText(prompt);

      if (response.isEmpty) {
        return '리포트를 불러오는 데 실패했습니다.';
      }

      final responseData = _geminiClient.decodeJsonObject(response);

      return responseData['reportText']?.toString() ?? '분석 결과를 해석할 수 없습니다.';
    } catch (e) {
      return '분석 중 오류가 발생했습니다: $e';
    }
  }
}
