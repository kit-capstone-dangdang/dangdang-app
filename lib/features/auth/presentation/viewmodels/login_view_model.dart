import 'package:dangdang/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:dangdang/core/presentation/providers/app_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this._authRepository);

  final FirebaseAuthRepository _authRepository;

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

  Future<String?> signIn() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      return '이메일과 비밀번호를 입력해 주세요.';
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      await _authRepository.signIn(email: email, password: password);
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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

final loginViewModelProvider = ChangeNotifierProvider.autoDispose<
  LoginViewModel
>((ref) {
  final viewModel = LoginViewModel(ref.watch(authRepositoryProvider));
  ref.onDispose(viewModel.dispose);
  return viewModel;
});
