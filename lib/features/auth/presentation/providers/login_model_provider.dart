import 'package:dangdang/core/presentation/providers/app_providers.dart';
import 'package:dangdang/features/auth/presentation/models/login_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loginProvider = ChangeNotifierProvider.autoDispose<
  LoginModel
>((ref) {
  final model = LoginModel(ref.watch(authRepositoryProvider));
  ref.onDispose(model.dispose);
  return model;
});
