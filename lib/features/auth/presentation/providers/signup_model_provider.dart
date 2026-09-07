import 'package:dangdang/core/presentation/providers/app_providers.dart';
import 'package:dangdang/features/auth/presentation/models/signup_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final signupProvider = ChangeNotifierProvider.autoDispose<
  SignupModel
>((ref) {
  final model = SignupModel(ref.watch(authRepositoryProvider));
  ref.onDispose(model.dispose);
  return model;
});
