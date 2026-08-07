class AiChatReply {
  final String answer;
  final List<String> suggestedQuestions;

  const AiChatReply({required this.answer, required this.suggestedQuestions});

  factory AiChatReply.fromJson(Map<String, dynamic> json) {
    final rawSuggestions =
        json['suggestedQuestions'] as List<dynamic>? ?? const [];

    return AiChatReply(
      answer: (json['answer'] ?? '').toString().trim(),
      suggestedQuestions: rawSuggestions
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .take(3)
          .toList(),
    );
  }
}