import 'package:dangdang/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:dangdang/features/profile/data/repositories/firebase_profile_repository.dart';
import 'package:flutter/foundation.dart';

class MyPageModel extends ChangeNotifier {
  MyPageModel(this._profileRepository, this._authRepository);

  final FirebaseProfileRepository _profileRepository;
  final FirebaseAuthRepository _authRepository;

  String _nickname = '';
  String _email = '';
  String _profileImageUrl = '';
  bool _isLoading = false;
  bool _initialized = false;

  String get nickname => _nickname;
  String get email => _email;
  String get profileImageUrl => _profileImageUrl;
  bool get isLoading => _isLoading;

  String get initial {
    if (_nickname.isEmpty) {
      return '';
    }

    return _nickname.substring(0, 1);
  }

  Future<void> loadUserInfo({bool force = false}) async {
    if (_initialized && !force) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final profile = await _profileRepository.getProfile();
      _nickname = profile?['nickname']?.toString() ?? '사용자';
      _email = profile?['email']?.toString() ?? '';
      _profileImageUrl = profile?['profileImageUrl']?.toString() ?? '';
      _initialized = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }
}
