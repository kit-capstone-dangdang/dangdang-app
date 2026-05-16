import 'package:flutter/material.dart';

import '../../data/repositories/firebase_auth_repository.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_label.dart';
import '../widgets/auth_text_field.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final FirebaseAuthRepository _authRepository = FirebaseAuthRepository();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _nicknameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  Future<void> _signUp() async {
    final name = _nameController.text.trim();
    final nickname = _nicknameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || nickname.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage('모든 항목을 입력해 주세요.');
      return;
    }

    try {
      await _authRepository.signUp(
        name: name,
        nickname: nickname,
        email: email,
        password: password,
      );

      if (!mounted) return;

      _showMessage('회원가입이 완료되었습니다.');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Row(
                  children: [
                    Icon(
                      Icons.arrow_back_ios,
                      size: 18,
                      color: Color(0xFF9CA3AF),
                    ),
                    Text(
                      '로그인으로 돌아가기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                '새로운 계정 만들기',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1C29),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '혈당 매니저와 함께 더 건강한\n내일을 만들어보세요.',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AuthLabel(text: '이름'),
                    const SizedBox(height: 12),
                    AuthTextField(
                      controller: _nameController,
                      hintText: '실명을 입력해 주세요',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 28),
                    const AuthLabel(text: '닉네임'),
                    const SizedBox(height: 12),
                    AuthTextField(
                      controller: _nicknameController,
                      hintText: '사용하실 별명을 입력하세요',
                      icon: Icons.edit_outlined,
                    ),
                    const SizedBox(height: 28),
                    const AuthLabel(text: '이메일 주소'),
                    const SizedBox(height: 12),
                    AuthTextField(
                      controller: _emailController,
                      hintText: 'name@example.com',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 28),
                    const AuthLabel(text: '비밀번호'),
                    const SizedBox(height: 12),
                    AuthTextField(
                      controller: _passwordController,
                      hintText: '6자리 이상 입력하세요',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xFFC4C6D0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    AuthButton(text: '회원가입 완료', onPressed: _signUp),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
