import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dangdang/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:dangdang/features/profile/presentation/widgets/profile_menu_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dangdang/core/widgets/common/profile_avatar.dart';
import 'package:dangdang/features/profile/presentation/pages/security_privacy_page.dart';
import 'package:dangdang/features/auth/presentation/pages/login_page.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String _nickname = '';
  String _email = '';
  String _profileImageUrl = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = snapshot.data();

    if (!mounted) return;

    setState(() {
      _nickname = data?['nickname']?.toString() ?? user.displayName ?? '사용자';
      _email = data?['email']?.toString() ?? user.email ?? '';
      _profileImageUrl = data?['profileImageUrl']?.toString() ?? '';
    });
  }

  String get _initial {
    if (_nickname.isEmpty) return '';
    return _nickname.characters.first;
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _goToEditProfilePage() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfilePage()),
    );

    if (updated == true) {
      await _loadUserInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    '마이페이지',
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
                padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color.fromARGB(255, 237, 238, 241),
                                width: 2,
                              ),
                            ),
                            child: ProfileAvatar(
                              radius: 86,
                              profileImageUrl: _profileImageUrl,
                              fallbackText: _initial,
                              textStyle: textTheme.displayMedium?.copyWith(
                                color: const Color(0xFF4F63F6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            '$_nickname님',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _email,
                            style: textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 70),
                    ProfileMenuCard(
                      icon: Icons.person_outline_rounded,
                      title: '내 정보 수정',
                      iconColor: const Color(0xFF4F63F6),
                      backgroundColor: const Color(0xFFF1F5FF),
                      onTap: _goToEditProfilePage,
                    ),
                    ProfileMenuCard(
                      icon: Icons.favorite_border_rounded,
                      title: '보호자 연결 관리',
                      iconColor: const Color(0xFFDC2626),
                      backgroundColor: const Color(0xFFFFF1F2),
                    ),
                    ProfileMenuCard(
                      icon: Icons.notifications_none_rounded,
                      title: '알림 설정',
                      iconColor: const Color(0xFFEA580C),
                      backgroundColor: const Color(0xFFFFF7ED),
                    ),
                    ProfileMenuCard(
                      icon: Icons.shield_outlined,
                      title: '보안 및 개인정보',
                      iconColor: const Color(0xFF16A34A),
                      backgroundColor: const Color(0xFFF0FDF4),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SecurityPrivacyPage(),
                          ),
                        );
                      },
                    ),
                    ProfileMenuCard(
                      icon: Icons.settings_outlined,
                      title: '앱 설정',
                      iconColor: const Color(0xFF4B5563),
                      backgroundColor: const Color(0xFFF9FAFB),
                    ),
                    const SizedBox(height: 20),
                    TextButton.icon(
                      onPressed: _logout,
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFEF4444),
                        size: 32,
                      ),
                      label: Text(
                        '로그아웃',
                        style: textTheme.titleMedium?.copyWith(
                          color: const Color(0xFFEF4444),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 78),
                    Center(
                      child: Text(
                        '버전 1.0.4 (최신버전)',
                        style: textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFD1D5DB),
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
