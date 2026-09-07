import 'package:dangdang/features/ai_chat/data/datasources/ai_chat_service.dart';
import 'package:dangdang/features/ai_chat/domain/entities/ai_chat_message.dart';
import 'package:dangdang/features/ai_chat/domain/entities/ai_chat_reply.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AiChatModel extends ChangeNotifier {
  AiChatModel(this._aiChatService) {
    messageController.addListener(_handleComposerChanged);
    _messages = [_buildWelcomeMessage()];
    _visibleSuggestions = List<String>.from(_starterQuestions);
  }

  final AiChatService _aiChatService;

  final TextEditingController messageController = TextEditingController();

  final List<String> _starterQuestions = const [
    '혈당 패턴 분석해줘',
    '식사별로 뭐가 문제인지 진단해줘',
    '공복 혈당 관리법 알려줘',
  ];

  late List<AiChatMessage> _messages;
  late List<String> _visibleSuggestions;

  bool _isLoading = false;
  String? _selectedSuggestion;
  int _conversationVersion = 0;

  List<AiChatMessage> get messages => _messages;
  List<String> get visibleSuggestions => _visibleSuggestions;
  bool get isLoading => _isLoading;
  String? get selectedSuggestion => _selectedSuggestion;
  bool get canSend => messageController.text.trim().isNotEmpty && !_isLoading;

  bool get hasUserConversation {
    return _messages.any((message) => message.sender == AiChatSender.user);
  }

  AiChatMessage _buildWelcomeMessage() {
    return AiChatMessage(
      text:
          '안녕하세요. 혈당 관리나 식단에 대해 궁금한 점이 있으시면 최근 기록을 함께 참고해서 맞춤형으로 안내해드릴게요.',
      sender: AiChatSender.assistant,
      createdAt: DateTime.now(),
    );
  }

  void _handleComposerChanged() {
    notifyListeners();
  }

  void resetConversation() {
    _conversationVersion++;
    messageController.clear();
    _isLoading = false;
    _selectedSuggestion = null;
    _messages = [_buildWelcomeMessage()];
    _visibleSuggestions = List<String>.from(_starterQuestions);
    notifyListeners();
  }

  Future<void> sendTextMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || _isLoading) {
      return;
    }

    messageController.clear();
    _selectedSuggestion = null;
    notifyListeners();
    await _sendQuestion(text);
  }

  Future<void> sendSuggestionMessage(String suggestion) async {
    if (_isLoading) {
      return;
    }

    _selectedSuggestion = suggestion;
    notifyListeners();
    await _sendQuestion(suggestion);
  }

  Future<void> _sendQuestion(String text) async {
    final userMessage = AiChatMessage(
      text: text,
      sender: AiChatSender.user,
      createdAt: DateTime.now(),
    );

    final requestVersion = _conversationVersion;
    _isLoading = true;
    _messages = [..._messages, userMessage];
    notifyListeners();

    try {
      final AiChatReply reply = await _aiChatService.askQuestion(
        question: text,
        conversation: _messages,
      );

      if (requestVersion != _conversationVersion) {
        return;
      }

      _isLoading = false;
      _messages = [
        ..._messages,
        AiChatMessage(
          text: reply.answer,
          sender: AiChatSender.assistant,
          createdAt: DateTime.now(),
        ),
      ];
      _visibleSuggestions = reply.suggestedQuestions.isEmpty
          ? List<String>.from(_starterQuestions)
          : reply.suggestedQuestions;
      notifyListeners();
    } catch (_) {
      if (requestVersion != _conversationVersion) {
        return;
      }

      _isLoading = false;
      _messages = [
        ..._messages,
        AiChatMessage(
          text: '답변을 불러오는 중 문제가 생겼어요. 잠시 후 다시 질문해 주세요.',
          sender: AiChatSender.assistant,
          createdAt: DateTime.now(),
        ),
      ];
      notifyListeners();
    }
  }

  @override
  void dispose() {
    messageController
      ..removeListener(_handleComposerChanged)
      ..dispose();
    super.dispose();
  }
}
