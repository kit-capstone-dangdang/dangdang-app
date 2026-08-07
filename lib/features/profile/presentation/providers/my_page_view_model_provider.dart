import 'package:dangdang/core/presentation/providers/app_providers.dart';
import 'package:dangdang/features/profile/presentation/viewmodels/my_page_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final myPageViewModelProvider = ChangeNotifierProvider.autoDispose<
  MyPageViewModel
>((ref) {
  return MyPageViewModel(
    ref.watch(profileRepositoryProvider),
    ref.watch(authRepositoryProvider),
  );
});
