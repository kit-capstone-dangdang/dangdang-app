import 'package:dangdang/core/presentation/providers/app_providers.dart';
import 'package:dangdang/features/profile/presentation/viewmodels/change_password_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final changePasswordViewModelProvider = ChangeNotifierProvider.autoDispose<
  ChangePasswordViewModel
>((ref) {
  final viewModel = ChangePasswordViewModel(ref.watch(firebaseAuthProvider));
  ref.onDispose(viewModel.dispose);
  return viewModel;
});
