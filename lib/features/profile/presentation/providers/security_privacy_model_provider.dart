import 'package:dangdang/core/presentation/providers/app_providers.dart';
import 'package:dangdang/features/profile/presentation/models/security_privacy_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final securityPrivacyProvider = ChangeNotifierProvider.autoDispose<
  SecurityPrivacyModel
>((ref) {
  final model = SecurityPrivacyModel(
    ref.watch(accountRepositoryProvider),
  );
  ref.onDispose(model.dispose);
  return model;
});
