import 'package:dangdang/core/presentation/providers/app_providers.dart';
import 'package:dangdang/features/auth/presentation/viewmodels/signup_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final signupViewModelProvider = ChangeNotifierProvider.autoDispose<
  SignupViewModel
>((ref) {
  final viewModel = SignupViewModel(ref.watch(authRepositoryProvider));
  ref.onDispose(viewModel.dispose);
  return viewModel;
});
