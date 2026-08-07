import 'package:dangdang/core/presentation/providers/app_providers.dart';
import 'package:dangdang/features/profile/presentation/viewmodels/security_privacy_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final securityPrivacyViewModelProvider = ChangeNotifierProvider.autoDispose<
  SecurityPrivacyViewModel
>((ref) {
  final viewModel = SecurityPrivacyViewModel(
    ref.watch(accountRepositoryProvider),
  );
  ref.onDispose(viewModel.dispose);
  return viewModel;
});
