import 'package:dangdang/features/auth/presentation/providers/signup_view_model_provider.dart';
import 'package:dangdang/features/auth/presentation/viewmodels/signup_view_model.dart';
import 'package:dangdang/features/auth/presentation/widgets/auth_button.dart';
import 'package:dangdang/features/auth/presentation/widgets/auth_label.dart';
import 'package:dangdang/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupPage extends ConsumerWidget {
  const SignupPage({super.key});

  Future<void> _signUp(BuildContext context, WidgetRef ref) async {
    final viewModel = ref.read(signupViewModelProvider);
    final message = await viewModel.signUp();

    if (!context.mounted) {
      return;
    }

    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('회원가입이 완료되었습니다.')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(signupViewModelProvider);

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
                '당당 매니저와 함께 내 건강한 일상을 만들어보세요.',
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
                      controller: viewModel.nameController,
                      hintText: '실명을 입력해 주세요',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 28),
                    const AuthLabel(text: '닉네임'),
                    const SizedBox(height: 12),
                    AuthTextField(
                      controller: viewModel.nicknameController,
                      hintText: '사용하실 별명을 입력하세요',
                      icon: Icons.edit_outlined,
                    ),
                    const SizedBox(height: 28),
                    const AuthLabel(text: '이메일 주소'),
                    const SizedBox(height: 12),
                    AuthTextField(
                      controller: viewModel.emailController,
                      hintText: 'name@example.com',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 28),
                    const AuthLabel(text: '비밀번호'),
                    const SizedBox(height: 12),
                    AuthTextField(
                      controller: viewModel.passwordController,
                      hintText: '6자리 이상 입력해 주세요',
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
                    const SizedBox(height: 40),
                    AuthButton(
                      text: viewModel.isSubmitting ? '가입 중..' : '회원가입 완료',
                      onPressed: () => _signUp(context, ref),
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
