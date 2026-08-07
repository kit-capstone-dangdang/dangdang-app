import 'package:dangdang/core/presentation/providers/app_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  ChangePasswordViewModel(this._auth);

  final FirebaseAuth _auth;

  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  bool get isLoading => _isLoading;
  bool get obscureCurrentPassword => _obscureCurrentPassword;
  bool get obscureNewPassword => _obscureNewPassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;

  void toggleCurrentPasswordVisibility() {
    _obscureCurrentPassword = !_obscureCurrentPassword;
    notifyListeners();
  }

  void toggleNewPasswordVisibility() {
    _obscureNewPassword = !_obscureNewPassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  Future<String?> changePassword() async {
    if (_isLoading) {
      return null;
    }

    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      return '모든 항목을 입력해 주세요.';
    }

    if (newPassword.length < 6) {
      return '새 비밀번호는 6자리 이상이어야 합니다.';
    }

    if (newPassword != confirmPassword) {
      return '새 비밀번호가 일치하지 않습니다.';
    }

    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;

      if (user == null || user.email == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return '현재 비밀번호가 올바르지 않습니다.';
      }
      if (e.code == 'weak-password') {
        return '새 비밀번호가 너무 약합니다.';
      }
      if (e.code == 'requires-recent-login') {
        return '보안을 위해 다시 로그인한 뒤 시도해 주세요.';
      }
      return '비밀번호 변경 중 오류가 발생했습니다.';
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}

final changePasswordViewModelProvider = ChangeNotifierProvider.autoDispose<
  ChangePasswordViewModel
>((ref) {
  final viewModel = ChangePasswordViewModel(ref.watch(firebaseAuthProvider));
  ref.onDispose(viewModel.dispose);
  return viewModel;
});