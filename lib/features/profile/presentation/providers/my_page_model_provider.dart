import 'package:dangdang/core/presentation/providers/app_providers.dart';
import 'package:dangdang/features/profile/presentation/models/my_page_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final myPageProvider = ChangeNotifierProvider.autoDispose<
  MyPageModel
>((ref) {
  return MyPageModel(
    ref.watch(profileRepositoryProvider),
    ref.watch(authRepositoryProvider),
  );
});
