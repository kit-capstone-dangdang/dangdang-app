import 'package:dangdang/features/auth/presentation/providers/signup_model_provider.dart';
import 'package:dangdang/features/auth/presentation/widgets/auth_button.dart';
import 'package:dangdang/features/auth/presentation/widgets/auth_label.dart';
import 'package:dangdang/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:dangdang/features/profile/presentation/widgets/profile_select_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupPage extends ConsumerWidget {
  const SignupPage({super.key});

  Future<void> _signUp(BuildContext context, WidgetRef ref) async {
    final model = ref.read(signupProvider);
    final message = await model.signUp();

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
    final model = ref.watch(signupProvider);
    final textTheme = Theme.of(context).textTheme;

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
                '새 계정 만들기',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1C29),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '혈당 매니저와 함께 더 건강한\n내일을 만들어보세요!',
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
                      controller: model.nameController,
                      hintText: '실명을 입력해 주세요',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 28),
                    const AuthLabel(text: '닉네임'),
                    const SizedBox(height: 12),
                    AuthTextField(
                      controller: model.nicknameController,
                      hintText: '닉네임을 입력해 주세요',
                      icon: Icons.edit_outlined,
                    ),
                    const SizedBox(height: 28),
                    const AuthLabel(text: '이메일 주소'),
                    const SizedBox(height: 12),
                    AuthTextField(
                      controller: model.emailController,
                      hintText: 'name@example.com',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 28),
                    const AuthLabel(text: '비밀번호'),
                    const SizedBox(height: 12),
                    AuthTextField(
                      controller: model.passwordController,
                      hintText: '6자리 이상 입력해 주세요',
                      icon: Icons.lock_outline,
                      obscureText: model.obscurePassword,
                      suffixIcon: IconButton(
                        onPressed: model.toggleObscurePassword,
                        icon: Icon(
                          model.obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xFFC4C6D0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const AuthLabel(text: '생년월일'),
                    const SizedBox(height: 12),
                    AuthTextField(
                      controller: model.birthController,
                      hintText: '생년월일을 선택해 주세요',
                      icon: Icons.calendar_today,
                      readOnly: true,
                      suffixIcon: const Icon(
                        Icons.calendar_today_outlined,
                        color: Color(0xFFC4C6D0),
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime(2000),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );

                        if (date == null) {
                          return;
                        }

                        model.updateBirthDate(
                          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    const AuthLabel(text: '성계'),
                    const SizedBox(height: 12),
                    Container(
                      height: 64,
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FB),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: const Color(0xFFF0F2F5)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ProfileSelectChip(
                              text: '남성',
                              selected: model.selectedGender == '남성',
                              selectedColor: const Color(0xFF4F63F6),
                              onTap: () {
                                model.selectGender('남성');
                              },
                            ),
                          ),
                          Expanded(
                            child: ProfileSelectChip(
                              text: '여성',
                              selected: model.selectedGender == '여성',
                              selectedColor: const Color(0xFFDC2626),
                              onTap: () {
                                model.selectGender('여성');
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AuthLabel(text: '키'),
                              const SizedBox(height: 12),
                              AuthTextField(
                                controller: model.heightController,
                                hintText: 'ex) 175',
                                keyboardType: TextInputType.number,
                                suffixText: 'cm',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AuthLabel(text: '몸무게'),
                              const SizedBox(height: 12),
                              AuthTextField(
                                controller: model.weightController,
                                hintText: 'ex) 70',
                                keyboardType: TextInputType.number,
                                suffixText: 'kg',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const AuthLabel(text: '당뇨 유형'),
                    const SizedBox(height: 12),
                    Row(
                      children: model.diabetesTypes.asMap().entries.map((
                        entry,
                      ) {
                        final index = entry.key;
                        final type = entry.value;

                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: index == model.diabetesTypes.length - 1
                                  ? 0
                                  : 5,
                            ),
                            child: SizedBox(
                              height: 46,
                              child: ProfileSelectChip(
                                text: type,
                                selected: model.selectedDiabetesType == type,
                                showBorderWhenUnselected: true,
                                selectedColor: const Color(0xFF4F63F6),
                                onTap: () {
                                  model.selectDiabetesType(type);
                                },
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),
                    AuthButton(
                      text: model.isSubmitting ? '가입 중..' : '회원가입 완료',
                      onPressed: model.isSubmitting
                          ? null
                          : () => _signUp(context, ref),
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
