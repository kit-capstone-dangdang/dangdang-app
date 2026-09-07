import 'package:dangdang/features/auth/presentation/pages/login_page.dart';
import 'package:dangdang/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:dangdang/features/profile/presentation/providers/security_privacy_model_provider.dart';
import 'package:dangdang/features/profile/presentation/widgets/security_privacy_menu_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class SecurityPrivacyPage extends ConsumerWidget {
  const SecurityPrivacyPage({super.key});

  static final Uri _privacyPolicyUri = Uri.parse(
    'https://dangdang-app.web.app/privacy.html',
  );
  static final Uri _termsUri = Uri.parse(
    'https://dangdang-app.web.app/terms.html',
  );

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final message = await ref.read(securityPrivacyProvider).deleteAccount();

    if (!context.mounted) {
      return;
    }

    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _openExternalUrl(BuildContext context, Uri uri) async {
    if (kIsWeb) {
      try {
        final launched = await launchUrl(uri, webOnlyWindowName: '_blank');

        if (!launched && context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('페이지를 열 수 없습니다.')));
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('페이지를 열 수 없습니다.')));
        }
      }
      return;
    }

    try {
      final launchModes = [LaunchMode.externalApplication, LaunchMode.platformDefault];

      for (final mode in launchModes) {
        try {
          final launched = await launchUrl(uri, mode: mode);

          if (launched) {
            return;
          }
        } catch (_) {
          continue;
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('페이지를 열 수 없습니다.')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('페이지를 열 수 없습니다.')));
      }
    }
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    final model = ref.read(securityPrivacyProvider);
    model.clearPassword();

    final textTheme = Theme.of(context).textTheme;

    showDialog<void>(
      context: context,
      barrierDismissible: !model.isDeleting,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (dialogContext) {
        return Consumer(
          builder: (context, ref, child) {
            final dialogModel = ref.watch(securityPrivacyProvider);

            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(horizontal: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(36),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(34, 48, 34, 34),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 112,
                        height: 112,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(56),
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFDC2626),
                          size: 64,
                        ),
                      ),
                      const SizedBox(height: 36),
                      Text(
                        '회원탈퇴',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '정말 탈퇴하시겠습니까?',
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '탈퇴 시 모든 식단 기록 및 혈당 기록이 삭제되며\n복구할 수 없습니다.',
                        textAlign: TextAlign.center,
                        style: textTheme.titleSmall?.copyWith(
                          color: const Color(0xFF9CA3AF),
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 28),
                      AuthTextField(
                        controller: dialogModel.passwordController,
                        hintText: '현재 비밀번호 입력',
                        icon: Icons.lock_outline,
                        obscureText: dialogModel.obscurePassword,
                        suffixIcon: IconButton(
                          onPressed: dialogModel.toggleObscurePassword,
                          icon: Icon(
                            dialogModel.obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xFFC4C6D0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 74,
                              child: OutlinedButton(
                                onPressed: dialogModel.isDeleting
                                    ? null
                                    : () {
                                        Navigator.pop(dialogContext);
                                      },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF9CA3AF),
                                  side: const BorderSide(
                                    color: Color(0xFFE5E7EB),
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                ),
                                child: Text(
                                  '취소',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 22),
                          Expanded(
                            child: SizedBox(
                              height: 74,
                              child: ElevatedButton(
                                onPressed: dialogModel.isDeleting
                                    ? null
                                    : () async {
                                        await _deleteAccount(context, ref);
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEF4444),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                ),
                                child: Text(
                                  dialogModel.isDeleting
                                      ? '탈퇴 중..'
                                      : '탈퇴하기',
                                  style: textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
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
                    '보안 및 개인정보',
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
                padding: const EdgeInsets.fromLTRB(30, 38, 30, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(34),
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
                        children: [
                          SecurityPrivacyMenuItem(
                            icon: Icons.verified_user_outlined,
                            title: '개인정보 처리방침',
                            iconColor: const Color(0xFF9CA3AF),
                            backgroundColor: const Color(0xFFF9FAFB),
                            textColor: const Color(0xFF1F2937),
                            onTap: () async {
                              await _openExternalUrl(context, _privacyPolicyUri);
                            },
                          ),
                          SecurityPrivacyMenuItem(
                            icon: Icons.description_outlined,
                            title: '이용약관',
                            iconColor: const Color(0xFF9CA3AF),
                            backgroundColor: const Color(0xFFF9FAFB),
                            textColor: const Color(0xFF1F2937),
                            onTap: () async {
                              await _openExternalUrl(context, _termsUri);
                            },
                          ),
                          SecurityPrivacyMenuItem(
                            icon: Icons.person_remove_alt_1_outlined,
                            title: '회원 탈퇴',
                            iconColor: const Color(0xFFEF4444),
                            backgroundColor: const Color(0xFFFFF1F2),
                            textColor: const Color(0xFFDC2626),
                            onTap: () {
                              _showDeleteAccountDialog(context, ref);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 56),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 42),
                      child: Text(
                        '당당케어는 사용자의 개인정보를 안전하게 보호하며, 관련 법령을 준수합니다. 궁금한 점이 있으시면 고객센터로 문의해 주세요.',
                        style: textTheme.titleSmall?.copyWith(
                          color: const Color(0xFF9CA3AF),
                          height: 1.6,
                          fontWeight: FontWeight.w500,
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
