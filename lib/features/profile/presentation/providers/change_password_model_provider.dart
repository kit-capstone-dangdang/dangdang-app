import 'package:dangdang/core/presentation/providers/app_providers.dart';
import 'package:dangdang/features/profile/presentation/models/change_password_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final changePasswordProvider = ChangeNotifierProvider.autoDispose<
  ChangePasswordModel
>((ref) {
  final model = ChangePasswordModel(ref.watch(firebaseAuthProvider));
  ref.onDispose(model.dispose);
  return model;
});
