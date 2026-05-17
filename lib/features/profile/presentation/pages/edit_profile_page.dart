import 'dart:io';
import 'package:dangdang/core/widgets/common/image_source_bottom_sheet.dart';
import 'package:dangdang/features/meal/data/services/image_picker_service.dart';
import 'package:dangdang/features/profile/data/repositories/firebase_profile_repository.dart';
import 'package:dangdang/features/profile/presentation/widgets/profile_form_card.dart';
import 'package:dangdang/features/profile/presentation/widgets/profile_section_title.dart';
import 'package:dangdang/features/profile/presentation/widgets/profile_select_chip.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dangdang/core/widgets/common/profile_avatar.dart';
import 'package:dangdang/features/profile/presentation/pages/change_password_page.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseProfileRepository _profileRepository =
      FirebaseProfileRepository();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _birthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String _email = '';
  String _profileImageUrl = '';
  String _selectedGender = '남성';
  String _selectedDiabetesType = '2형';

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingImage = false;

  final List<String> _diabetesTypes = ['1형', '2형', '임신성', '전단계'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _birthController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileRepository.getProfile();

      if (!mounted) return;

      setState(() {
        _nameController.text = profile?['name']?.toString() ?? '';
        _nicknameController.text = profile?['nickname']?.toString() ?? '';
        _birthController.text = profile?['birthDate']?.toString() ?? '';
        _heightController.text = profile?['height']?.toString() ?? '';
        _weightController.text = profile?['weight']?.toString() ?? '';
        _email = profile?['email']?.toString() ?? '';
        _profileImageUrl = profile?['profileImageUrl']?.toString() ?? '';

        final gender = profile?['gender']?.toString() ?? '';
        final diabetesType = profile?['diabetesType']?.toString() ?? '';

        _selectedGender = gender.isEmpty ? '남성' : gender;
        _selectedDiabetesType = diabetesType.isEmpty ? '2형' : diabetesType;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _selectBirthDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(1985, 5, 12),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) return;

    setState(() {
      _birthController.text =
          '${pickedDate.year.toString().padLeft(4, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
    });
  }

  Future<String> _uploadProfileImage(XFile image) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('로그인이 필요합니다.');
    }

    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child('${user.uid}.jpg');

    await ref.putFile(
      File(image.path),
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return ref.getDownloadURL();
  }

  Future<void> _pickProfileImage({
    required BuildContext context,
    required Future<XFile?> Function() pickImage,
  }) async {
    Navigator.pop(context);

    final image = await pickImage();

    if (image == null || !mounted) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final imageUrl = await _uploadProfileImage(image);

      await _profileRepository.updateProfileImageUrl(imageUrl);

      if (!mounted) return;

      setState(() {
        _profileImageUrl = imageUrl;
        _isUploadingImage = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('프로필 사진이 변경되었습니다.')));
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isUploadingImage = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _showProfileImageBottomSheet(BuildContext context) {
    final imagePickerService = ImagePickerService();
    final parentContext = context;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ImageSourceBottomSheet(
          onCameraTap: () async {
            await _pickProfileImage(
              context: parentContext,
              pickImage: imagePickerService.pickFromCamera,
            );
          },
          onGalleryTap: () async {
            await _pickProfileImage(
              context: parentContext,
              pickImage: imagePickerService.pickFromGallery,
            );
          },
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _profileRepository.updateProfile(
        name: _nameController.text.trim(),
        nickname: _nicknameController.text.trim(),
        birthDate: _birthController.text.trim(),
        gender: _selectedGender,
        height: int.tryParse(_heightController.text.trim()) ?? 0,
        weight: int.tryParse(_weightController.text.trim()) ?? 0,
        diabetesType: _selectedDiabetesType,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });
    }
  }

  void _cancelEdit() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4F63F6);
    const textColor = Color(0xFF111827);
    final textTheme = Theme.of(context).textTheme;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                    '내 정보 수정',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 24, 30, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ProfileAvatar(
                        radius: 86,
                        profileImageUrl: _profileImageUrl,
                        fallbackText: _nameController.text.isEmpty
                            ? ''
                            : _nameController.text.characters.first,
                        isLoading: _isUploadingImage,
                        textStyle: textTheme.displayMedium?.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        onTap: _isUploadingImage
                            ? null
                            : () {
                                _showProfileImageBottomSheet(context);
                              },
                        overlayWidget: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            color: Color(0xFF4B5563),
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 54),
                    const ProfileSectionTitle(
                      icon: Icons.info_outline,
                      iconColor: primaryColor,
                      title: '기본 정보',
                    ),
                    const SizedBox(height: 24),
                    const _ProfileLabel('이름'),
                    ProfileFormCard(
                      controller: _nameController,
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 28),
                    const _ProfileLabel('닉네임'),
                    ProfileFormCard(
                      controller: _nicknameController,
                      icon: Icons.edit_outlined,
                    ),
                    const SizedBox(height: 28),
                    const _ProfileLabel('계정 정보'),
                    Container(
                      width: double.infinity,
                      height: 78,
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: const Color(0xFFF1F3F7)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.mail_outline,
                            color: Color(0xFF9CA3AF),
                            size: 28,
                          ),
                          const SizedBox(width: 22),
                          Text(
                            _email,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 34),
                    SizedBox(
                      width: double.infinity,
                      height: 78,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ChangePasswordPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.lock_outline, size: 26),
                        label: Text(
                          '비밀번호 변경하기',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6B7280),
                          side: const BorderSide(
                            color: Color(0xFFE5E7EB),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 54),
                    const ProfileSectionTitle(
                      icon: Icons.monitor_heart_outlined,
                      iconColor: Color(0xFFEF4444),
                      title: '신체 및 건강 정보',
                    ),
                    const SizedBox(height: 24),
                    const _ProfileLabel('생년월일'),
                    GestureDetector(
                      onTap: _selectBirthDate,
                      child: AbsorbPointer(
                        child: ProfileFormCard(
                          controller: _birthController,
                          icon: Icons.calendar_month_outlined,
                          suffixIcon: Icons.calendar_today_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const _ProfileLabel('성별'),
                    Container(
                      height: 78,
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
                              selected: _selectedGender == '남성',
                              selectedColor: primaryColor,
                              onTap: () {
                                setState(() {
                                  _selectedGender = '남성';
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: ProfileSelectChip(
                              text: '여성',
                              selected: _selectedGender == '여성',
                              selectedColor: const Color(0xFFDC2626),
                              onTap: () {
                                setState(() {
                                  _selectedGender = '여성';
                                });
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
                              const _ProfileLabel('키'),
                              ProfileFormCard(
                                controller: _heightController,
                                suffixText: 'cm',
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _ProfileLabel('몸무게'),
                              ProfileFormCard(
                                controller: _weightController,
                                suffixText: 'kg',
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const _ProfileLabel('당뇨 유형'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _diabetesTypes.map((type) {
                        return SizedBox(
                          width: 78,
                          height: 46,
                          child: ProfileSelectChip(
                            text: type,
                            selected: _selectedDiabetesType == type,
                            showBorderWhenUnselected: true,
                            selectedColor: primaryColor,
                            onTap: () {
                              setState(() {
                                _selectedDiabetesType = type;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 54),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 74,
                            child: OutlinedButton(
                              onPressed: _isSaving ? null : _cancelEdit,
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
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: Text(
                                _isSaving ? '저장 중...' : '수정완료',
                                style: textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
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

class _ProfileLabel extends StatelessWidget {
  final String text;

  const _ProfileLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 10),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: const Color(0xFF9CA3AF),
        ),
      ),
    );
  }
}
