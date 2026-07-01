import 'package:dangdang/features/ai_chat/data/services/ai_chat_service.dart';
import 'package:dangdang/features/ai_chat/domain/entities/ai_chat_message.dart';
import 'package:dangdang/features/ai_chat/domain/entities/ai_chat_reply.dart';
import 'package:dangdang/features/ai_chat/presentation/widgets/ai_chat_bubble.dart';
import 'package:flutter/material.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final AiChatService _aiChatService = AiChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _starterQuestions = const [
    '혈당 패턴 분석해줘',
    '탄수화물 섭취 진단해줘',
    '공복 혈당 관리법은?',
  ];

  late List<AiChatMessage> _messages;
  late List<String> _visibleSuggestions;

  bool _isLoading = false;
  String? _selectedSuggestion;
  int _conversationVersion = 0;

  @override
  void initState() {
    super.initState();
    _messages = [_buildWelcomeMessage()];
    _visibleSuggestions = List<String>.from(_starterQuestions);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  AiChatMessage _buildWelcomeMessage() {
    return AiChatMessage(
      text: '안녕하세요! 혈당 관리나 식단에 대해 궁금한 점이 있으신가요? 최근 기록을 함께 참고해서 맞춤형으로 도와드릴게요.',
      sender: AiChatSender.assistant,
      createdAt: DateTime.now(),
    );
  }

  void _resetConversation() {
    _conversationVersion++;
    _messageController.clear();
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = false;
      _selectedSuggestion = null;
      _messages = [_buildWelcomeMessage()];
      _visibleSuggestions = List<String>.from(_starterQuestions);
    });

    _scrollToBottom();
  }

  Future<void> _sendTextMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    _messageController.clear();
    _selectedSuggestion = null;
    await _sendQuestion(text);
  }

  Future<void> _sendSuggestionMessage(String suggestion) async {
    if (_isLoading) return;

    setState(() {
      _selectedSuggestion = suggestion;
    });

    await _sendQuestion(suggestion);
  }

  Future<void> _sendQuestion(String text) async {
    final userMessage = AiChatMessage(
      text: text,
      sender: AiChatSender.user,
      createdAt: DateTime.now(),
    );

    final requestVersion = _conversationVersion;

    setState(() {
      _isLoading = true;
      _messages = [..._messages, userMessage];
    });

    _scrollToBottom();

    try {
      final AiChatReply reply = await _aiChatService.askQuestion(
        question: text,
        conversation: _messages,
      );

      if (!mounted || requestVersion != _conversationVersion) return;

      setState(() {
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
      });

      _scrollToBottom();
    } catch (_) {
      if (!mounted || requestVersion != _conversationVersion) return;

      setState(() {
        _isLoading = false;
        _messages = [
          ..._messages,
          AiChatMessage(
            text: '답변을 불러오는 중 문제가 생겼어요. 잠시 후 다시 질문해 주세요.',
            sender: AiChatSender.assistant,
            createdAt: DateTime.now(),
          ),
        ];
      });

      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  bool get _hasUserConversation {
    return _messages.any((message) => message.sender == AiChatSender.user);
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _messageController.text.trim().isNotEmpty && !_isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                children: [
                  _buildWarningBanner(),
                  const SizedBox(height: 18),
                  ..._messages.map(
                    (message) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: AiChatBubble(message: message),
                    ),
                  ),
                  if (_isLoading)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        '답변을 정리하고 있어요...',
                        style: TextStyle(
                          color: Color(0xFF667085),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (!_isLoading) ...[
                    const SizedBox(height: 4),
                    _buildSuggestionSection(),
                  ],
                ],
              ),
            ),
            _buildComposer(canSend),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF3FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Color(0xFF8DA2FB),
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '당뇨케어 1:1 AI 상담',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF101828),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.circle, color: Color(0xFF7BC47F), size: 10),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '전문 혈당 분석 시스템 가동중',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFF9BD18F),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: TextButton.icon(
              onPressed: _resetConversation,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFF98A2B3),
                size: 18,
              ),
              label: const Text(
                '초기화',
                style: TextStyle(
                  color: Color(0xFF98A2B3),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE2A8)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFFF59E0B), size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'AI 상담 내용은 건강관리 참고용입니다. 증상이 있거나 약물, 치료 판단이 필요한 경우에는 반드시 의료진과 상담해 주세요.',
              style: TextStyle(
                color: Color(0xFF7A5A00),
                fontSize: 12,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionSection() {
    if (_visibleSuggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    final title = _hasUserConversation
        ? '이어서 이런 것도 물어볼 수 있어요.'
        : '어떻게 질문해야 할지 모르겠다면 아래 예시를 선택해 보세요.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF667085),
            fontSize: 14,
            height: 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ..._visibleSuggestions.map(
          (question) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildSuggestionChip(question),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionChip(String question) {
    final isSelected = _selectedSuggestion == question;

    return GestureDetector(
      onTap: () => _sendSuggestionMessage(question),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A63F6) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          question,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF344054),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildComposer(bool canSend) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F8FC),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFE6EAF2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _sendTextMessage(),
                minLines: 1,
                maxLines: 4,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  hintText: '식단, 수면, 혈당에 대해 무엇이든 물어보세요',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Color(0xFF98A2B3),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: canSend ? _sendTextMessage : null,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: canSend
                      ? const Color(0xFFDEE5FF)
                      : const Color(0xFFF0F2F7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.send_rounded,
                  size: 22,
                  color: canSend
                      ? const Color(0xFF7A8AEF)
                      : const Color(0xFFB7BFCC),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
