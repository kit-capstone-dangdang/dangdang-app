import 'package:dangdang/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SignupModel extends ChangeNotifier {
  SignupModel(this._authRepository);

  final FirebaseAuthRepository _authRepository;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController birthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String _selectedGender = '남성';
  String _selectedDiabetesType = '2형';

  bool get obscurePassword => _obscurePassword;
  bool get isSubmitting => _isSubmitting;
  String get selectedGender => _selectedGender;
  String get selectedDiabetesType => _selectedDiabetesType;
  List<String> get diabetesTypes => const ['1형', '2형', '임신성', '기타'];

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void updateBirthDate(String birthDate) {
    birthController.text = birthDate;
    notifyListeners();
  }

  void selectGender(String gender) {
    _selectedGender = gender;
    notifyListeners();
  }

  void selectDiabetesType(String diabetesType) {
    _selectedDiabetesType = diabetesType;
    notifyListeners();
  }

  Future<String?> signUp() async {
    if (_isSubmitting) {
      return null;
    }

    final name = nameController.text.trim();
    final nickname = nicknameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final birthDate = birthController.text.trim();
    final height = heightController.text.trim();
    final weight = weightController.text.trim();

    if (name.isEmpty ||
        nickname.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        birthDate.isEmpty ||
        height.isEmpty ||
        weight.isEmpty) {
      return '모든 항목을 입력해 주세요';
    }

    if (password.length < 6) {
      return '비밀번호는 6자리 이상 입력해 주세요';
    }

    final parsedHeight = int.tryParse(height);
    final parsedWeight = int.tryParse(weight);

    if (parsedHeight == null || parsedWeight == null) {
      return '키와 몸무게는 숫자로 입력해 주세요';
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      await _authRepository.signUp(
        name: name,
        nickname: nickname,
        email: email,
        password: password,
        birthDate: birthDate,
        gender: _selectedGender,
        height: parsedHeight,
        weight: parsedWeight,
        diabetesType: _selectedDiabetesType,
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
    birthController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }
}
