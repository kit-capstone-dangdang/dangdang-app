import 'package:dangdang/core/presentation/providers/app_providers.dart';
import 'package:dangdang/features/auth/presentation/viewmodels/login_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loginViewModelProvider = ChangeNotifierProvider.autoDispose<
  LoginViewModel
>((ref) {
  final viewModel = LoginViewModel(ref.watch(authRepositoryProvider));
  ref.onDispose(viewModel.dispose);
  return viewModel;
});
