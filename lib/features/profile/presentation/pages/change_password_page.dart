import 'package:dangdang/features/auth/presentation/widgets/auth_button.dart';
import 'package:dangdang/features/auth/presentation/widgets/auth_label.dart';
import 'package:dangdang/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_isLoading) return;

    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showSnackBar('모든 항목을 입력해주세요.');
      return;
    }

    if (newPassword.length < 6) {
      _showSnackBar('새 비밀번호는 6자 이상이어야 합니다.');
      return;
    }

    if (newPassword != confirmPassword) {
      _showSnackBar('새 비밀번호가 일치하지 않습니다.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null || user.email == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('비밀번호가 변경되었습니다.')));

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        _showSnackBar('현재 비밀번호가 올바르지 않습니다.');
      } else if (e.code == 'weak-password') {
        _showSnackBar('새 비밀번호가 너무 약합니다.');
      } else if (e.code == 'requires-recent-login') {
        _showSnackBar('보안을 위해 다시 로그인한 뒤 시도해주세요.');
      } else {
        _showSnackBar('비밀번호 변경 중 오류가 발생했습니다.');
      }
    } catch (e) {
      _showSnackBar(e.toString());
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4F63F6);
    final textTheme = Theme.of(context).textTheme;

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
                            '안전을 위해 정기적으로 비밀번호를 변경해주세요.',
                            style: textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF9CA3AF),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 40),
                          const AuthLabel(text: '현재 비밀번호'),
                          const SizedBox(height: 10),
                          AuthTextField(
                            controller: _currentPasswordController,
                            hintText: '현재 비밀번호 입력',
                            icon: Icons.lock_outline,
                            obscureText: _obscureCurrentPassword,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureCurrentPassword =
                                      !_obscureCurrentPassword;
                                });
                              },
                              icon: Icon(
                                _obscureCurrentPassword
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
                            controller: _newPasswordController,
                            hintText: '새 비밀번호 입력 (6자 이상)',
                            icon: Icons.lock_outline,
                            obscureText: _obscureNewPassword,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                              icon: Icon(
                                _obscureNewPassword
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
                            controller: _confirmPasswordController,
                            hintText: '새 비밀번호 다시 입력',
                            icon: Icons.check_circle_outline,
                            obscureText: _obscureConfirmPassword,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                              icon: Icon(
                                _obscureConfirmPassword
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
                          onPressed: _isLoading
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
                          text: _isLoading ? '변경 중...' : '비밀번호 변경',
                          onPressed: _changePassword,
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
