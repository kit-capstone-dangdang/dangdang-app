import 'package:dangdang/features/profile/data/repositories/firebase_account_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SecurityPrivacyViewModel extends ChangeNotifier {
  SecurityPrivacyViewModel(this._accountRepository);

  final FirebaseAccountRepository _accountRepository;

  final TextEditingController passwordController = TextEditingController();

  bool _isDeleting = false;
  bool _obscurePassword = true;

  bool get isDeleting => _isDeleting;
  bool get obscurePassword => _obscurePassword;

  void clearPassword() {
    passwordController.clear();
    notifyListeners();
  }

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  Future<String?> deleteAccount() async {
    if (_isDeleting) {
      return null;
    }

    final currentPassword = passwordController.text.trim();

    if (currentPassword.isEmpty) {
      return '현재 비밀번호를 입력해 주세요.';
    }

    _isDeleting = true;
    notifyListeners();

    try {
      await _accountRepository.deleteAccount(currentPassword: currentPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return '현재 비밀번호가 올바르지 않습니다.';
      }
      if (e.code == 'requires-recent-login') {
        return '보안을 위해 다시 로그인한 뒤 시도해 주세요.';
      }
      return '회원탈퇴 중 오류가 발생했습니다.';
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }
}
