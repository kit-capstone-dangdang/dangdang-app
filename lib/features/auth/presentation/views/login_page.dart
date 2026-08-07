import 'package:dangdang/app/presentation/navigation/main_shell.dart';
import 'package:dangdang/features/auth/presentation/viewmodels/login_view_model.dart';
import 'package:dangdang/features/auth/presentation/views/signup_page.dart';
import 'package:dangdang/features/auth/presentation/widgets/auth_button.dart';
import 'package:dangdang/features/auth/presentation/widgets/auth_label.dart';
import 'package:dangdang/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  Future<void> _signIn(BuildContext context, WidgetRef ref) async {
    final viewModel = ref.read(loginViewModelProvider);
    final message = await viewModel.signIn();

    if (!context.mounted) {
      return;
    }

    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(loginViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: Image.asset(
                  'assets/images/app_icon.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '당당하게',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '건강 관리, 당당하게 시작해보세요!',
                style: TextStyle(fontSize: 16, color: Color(0xFF8A8D9F)),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                '로그인',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignupPage(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: const Center(
                                child: Text(
                                  '회원가입',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF8A8D9F),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const AuthLabel(text: '이메일 주소'),
                    const SizedBox(height: 8),
                    AuthTextField(
                      controller: viewModel.emailController,
                      hintText: 'name@example.com',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),
                    const AuthLabel(text: '비밀번호'),
                    const SizedBox(height: 8),
                    AuthTextField(
                      controller: viewModel.passwordController,
                      hintText: '비밀번호를 입력하세요',
                      icon: Icons.lock_outline,
                      obscureText: viewModel.obscurePassword,
                      suffixIcon: IconButton(
                        onPressed: viewModel.toggleObscurePassword,
                        icon: Icon(
                          viewModel.obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xFFC4C6D0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    AuthButton(
                      text: viewModel.isSubmitting ? '로그인 중..' : '로그인',
                      onPressed: () => _signIn(context, ref),
                    ),
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
