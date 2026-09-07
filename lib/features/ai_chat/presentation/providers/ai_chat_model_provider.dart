import 'package:dangdang/core/presentation/providers/app_providers.dart';
import 'package:dangdang/features/ai_chat/presentation/models/ai_chat_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final aiChatProvider = ChangeNotifierProvider.autoDispose<
  AiChatModel
>((ref) {
  final model = AiChatModel(ref.watch(aiChatServiceProvider));
  ref.onDispose(model.dispose);
  return model;
});
