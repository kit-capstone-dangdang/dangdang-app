enum AiChatSender { user, assistant }

class AiChatMessage {
  final String text;
  final AiChatSender sender;
  final DateTime createdAt;

  const AiChatMessage({
    required this.text,
    required this.sender,
    required this.createdAt,
  });

  bool get isUser => sender == AiChatSender.user;

  Map<String, dynamic> toPromptJson() {
    return {
      'role': isUser ? 'user' : 'assistant',
      'message': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
