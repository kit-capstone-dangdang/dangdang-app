import 'package:dangdang/features/auth/presentation/widgets/auth_button.dart';
import 'package:dangdang/features/auth/presentation/widgets/auth_label.dart';
import 'package:dangdang/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:dangdang/features/profile/presentation/viewmodels/change_password_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangePasswordPage extends ConsumerWidget {
  const ChangePasswordPage({super.key});

  Future<void> _changePassword(BuildContext context, WidgetRef ref) async {
    final message = await ref.read(changePasswordViewModelProvider).changePassword();

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
    ).showSnackBar(const SnackBar(content: Text('비밀번호가 변경되었습니다.')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryColor = Color(0xFF4F63F6);
    final textTheme = Theme.of(context).textTheme;
    final viewModel = ref.watch(changePasswordViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  snap: false,
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  toolbarHeight: 80,
                  titleSpacing: 20,
                  title: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '비밀번호 변경',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30, 50, 30, 150),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(28, 56, 28, 48),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(42),
                        border: Border.all(
                          color: const Color.fromARGB(255, 237, 238, 241),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 118,
                              height: 118,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F4FF),
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: const Icon(
                                Icons.lock_outline_rounded,
                                color: primaryColor,
                                size: 58,
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),
                          Center(
                            child: Text(
                              '새 비밀번호 설정',
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF111827),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            '안전을 위해 정기적으로 비밀번호를 변경해 주세요.',
                            style: textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF9CA3AF),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 40),
                          const AuthLabel(text: '현재 비밀번호'),
                          const SizedBox(height: 10),
                          AuthTextField(
                            controller: viewModel.currentPasswordController,
                            hintText: '현재 비밀번호 입력',
                            icon: Icons.lock_outline,
                            obscureText: viewModel.obscureCurrentPassword,
                            suffixIcon: IconButton(
                              onPressed: viewModel.toggleCurrentPasswordVisibility,
                              icon: Icon(
                                viewModel.obscureCurrentPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFFC4C6D0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),
                          const Divider(color: Color(0xFFF1F3F7)),
                          const SizedBox(height: 36),
                          const AuthLabel(text: '새 비밀번호'),
                          const SizedBox(height: 10),
                          AuthTextField(
                            controller: viewModel.newPasswordController,
                            hintText: '새 비밀번호 입력 (6자리 이상)',
                            icon: Icons.lock_outline,
                            obscureText: viewModel.obscureNewPassword,
                            suffixIcon: IconButton(
                              onPressed: viewModel.toggleNewPasswordVisibility,
                              icon: Icon(
                                viewModel.obscureNewPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFFC4C6D0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          const AuthLabel(text: '새 비밀번호 확인'),
                          const SizedBox(height: 10),
                          AuthTextField(
                            controller: viewModel.confirmPasswordController,
                            hintText: '새 비밀번호 다시 입력',
                            icon: Icons.check_circle_outline,
                            obscureText: viewModel.obscureConfirmPassword,
                            suffixIcon: IconButton(
                              onPressed:
                                  viewModel.toggleConfirmPasswordVisibility,
                              icon: Icon(
                                viewModel.obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFFC4C6D0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 30,
              right: 30,
              bottom: 24,
              child: Container(
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 74,
                        child: OutlinedButton(
                          onPressed: viewModel.isLoading
                              ? null
                              : () {
                                  Navigator.pop(context);
                                },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF6B7280),
                            side: const BorderSide(
                              color: Color(0xFFD1D5DB),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            '취소',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: SizedBox(
                        height: 74,
                        child: AuthButton(
                          text: viewModel.isLoading
                              ? '변경 중..'
                              : '비밀번호 변경',
                          onPressed: () => _changePassword(context, ref),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
