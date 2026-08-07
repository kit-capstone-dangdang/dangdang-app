import 'package:dangdang/core/presentation/providers/app_providers.dart';
import 'package:dangdang/features/ai_chat/presentation/viewmodels/ai_chat_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final aiChatViewModelProvider = ChangeNotifierProvider.autoDispose<
  AiChatViewModel
>((ref) {
  final viewModel = AiChatViewModel(ref.watch(aiChatServiceProvider));
  ref.onDispose(viewModel.dispose);
  return viewModel;
});
