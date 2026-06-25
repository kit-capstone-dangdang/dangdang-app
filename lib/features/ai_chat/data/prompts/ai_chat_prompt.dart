import 'dart:convert';

String buildAiChatPrompt({
  required Map<String, dynamic>? profile,
  required List<Map<String, dynamic>> bloodSugarRecords,
  required List<Map<String, dynamic>> mealRecords,
  required List<Map<String, dynamic>> conversationHistory,
  required String userQuestion,
}) {
  final profileJson = jsonEncode(profile ?? {});
  final bloodSugarJson = jsonEncode(bloodSugarRecords);
  final mealJson = jsonEncode(mealRecords);
  final historyJson = jsonEncode(conversationHistory);

  return '''
너는 당당 앱의 1:1 건강 상담 AI다.
기록과 최근 대화를 바탕으로 한국어 존댓말로 짧고 실용적으로 답해.

규칙:
- 기록 기반 개인화 조언만 제공
- 진단, 약 처방, 복용 변경 지시 금지
- 경고문, 면책문, 같은 말 반복 금지
- 마크다운, 제목, 코드블록 금지
- answer는 3~5문장, 핵심 분석 1~2개와 바로 실천할 행동 1개 포함
- suggestedQuestions는 3개, 짧고 눌러보기 쉬운 질문으로 작성
- 반드시 JSON 객체만 반환

반환 형식:
{"answer":"...","suggestedQuestions":["...","...","..."]}

profile: $profileJson
bloodSugarRecords: $bloodSugarJson
mealRecords: $mealJson
conversationHistory: $historyJson
userQuestion: $userQuestion
''';
}
