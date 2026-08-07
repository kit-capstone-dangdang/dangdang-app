import 'package:dangdang/features/ai_chat/domain/entities/ai_chat_message.dart';
import 'package:dangdang/features/ai_chat/presentation/viewmodels/ai_chat_view_model.dart';
import 'package:dangdang/features/ai_chat/presentation/widgets/ai_chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendTextMessage() async {
    await ref.read(aiChatViewModelProvider).sendTextMessage();
    _scrollToBottom();
  }

  Future<void> _sendSuggestionMessage(String suggestion) async {
    await ref.read(aiChatViewModelProvider).sendSuggestionMessage(suggestion);
    _scrollToBottom();
  }

  void _resetConversation() {
    FocusScope.of(context).unfocus();
    ref.read(aiChatViewModelProvider).resetConversation();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(aiChatViewModelProvider);

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
                  ...viewModel.messages.map(
                    (message) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: AiChatBubble(message: message),
                    ),
                  ),
                  if (viewModel.isLoading)
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
                        '답변을 정리하고 있어요..',
                        style: TextStyle(
                          color: Color(0xFF667085),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (!viewModel.isLoading) ...[
                    const SizedBox(height: 4),
                    _buildSuggestionSection(viewModel),
                  ],
                ],
              ),
            ),
            _buildComposer(viewModel),
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
                          '전문 혈당 분석 어시스턴트 가동중',
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
              'AI 상담 내용은 건강관리 참고용입니다. 증상이나 치료 판단이 필요한 경우에는 반드시 의료진과 상담해 주세요.',
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

  Widget _buildSuggestionSection(AiChatViewModel viewModel) {
    if (viewModel.visibleSuggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    final title = viewModel.hasUserConversation
        ? '이어서 이런 것도 물어볼 수 있어요'
        : '어떻게 질문해야 좋을지 모르겠다면 아래 예시를 눌러보세요';

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
        ...viewModel.visibleSuggestions.map(
          (question) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildSuggestionChip(viewModel, question),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionChip(AiChatViewModel viewModel, String question) {
    final isSelected = viewModel.selectedSuggestion == question;

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

  Widget _buildComposer(AiChatViewModel viewModel) {
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
                controller: viewModel.messageController,
                onSubmitted: (_) => _sendTextMessage(),
                minLines: 1,
                maxLines: 4,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  hintText: '식단, 생활, 혈당 등 어떤 것이든 물어보세요',
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
              onTap: viewModel.canSend ? _sendTextMessage : null,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: viewModel.canSend
                      ? const Color(0xFFDEE5FF)
                      : const Color(0xFFF0F2F7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.send_rounded,
                  size: 22,
                  color: viewModel.canSend
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