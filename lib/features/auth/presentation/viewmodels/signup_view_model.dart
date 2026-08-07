import 'package:dangdang/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:dangdang/core/presentation/providers/app_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupViewModel extends ChangeNotifier {
  SignupViewModel(this._authRepository);

  final FirebaseAuthRepository _authRepository;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;

  bool get obscurePassword => _obscurePassword;
  bool get isSubmitting => _isSubmitting;

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  Future<String?> signUp() async {
    final name = nameController.text.trim();
    final nickname = nicknameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty ||
        nickname.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      return '모든 항목을 입력해 주세요.';
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      await _authRepository.signUp(
        name: name,
        nickname: nickname,
        email: email,
        password: password,
      );
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    nicknameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

final signupViewModelProvider = ChangeNotifierProvider.autoDispose<
  SignupViewModel
>((ref) {
  final viewModel = SignupViewModel(ref.watch(authRepositoryProvider));
  ref.onDispose(viewModel.dispose);
  return viewModel;
});
