import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:dangdang/core/widgets/common/custom_card.dart';
import 'package:dangdang/core/widgets/common/custom_icon.dart';
import 'package:dangdang/core/widgets/common/state_views.dart';
import 'package:dangdang/features/meal/data/services/image_picker_service.dart';
import 'package:dangdang/features/meal/data/services/meal_ai_service.dart';
import 'package:dangdang/features/meal/presentation/pages/analysis_result_page.dart';
import 'package:dangdang/features/blood_glucose/presentation/pages/blood_glucose_analysis_page.dart';
import 'package:dangdang/features/blood_glucose/presentation/pages/blood_glucose_add_page.dart';
import 'package:dangdang/features/blood_glucose/presentation/widgets/blood_glucose_line_chart.dart';
import 'package:dangdang/features/blood_glucose/domain/entities/blood_glucose_record.dart';
import 'package:dangdang/features/blood_glucose/data/repositories/firebase_blood_glucose_repository.dart';
import 'package:dangdang/features/profile/presentation/pages/my_page.dart';

class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  bool _isLoading = false;
  bool _isLoadingBloodSugar = true;

  String _userName = '사용자';

  final FirebaseBloodSugarRepository _bloodSugarRepo =
      FirebaseBloodSugarRepository();
  BloodSugarRecord? _latestRecord;
  List<BloodSugarRecord> _recentChartRecords = [];
  List<FlSpot> _chartSpots = [];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadHomeBloodSugarData();
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
      _userName = data?['name']?.toString() ?? user.displayName ?? '사용자';
    });
  }

  String get _userInitial {
    if (_userName.isEmpty) return '';
    return _userName.characters.first;
  }

  Future<void> _loadHomeBloodSugarData() async {
    try {
      final records = await _bloodSugarRepo.getRecords();

      if (records.isEmpty) {
        if (mounted) {
          setState(() {
            _latestRecord = null;
            _recentChartRecords = [];
            _chartSpots = [];
            _isLoadingBloodSugar = false;
          });
        }
        return;
      }

      var sortedDesc = List<BloodSugarRecord>.from(records);
      sortedDesc.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      final latest = sortedDesc.first;

      var recent = sortedDesc.take(7).toList();
      recent.sort((a, b) => a.dateTime.compareTo(b.dateTime));

      List<FlSpot> spots = [];
      for (int i = 0; i < recent.length; i++) {
        spots.add(FlSpot(i.toDouble(), recent[i].bloodSugar.toDouble()));
      }

      if (mounted) {
        setState(() {
          _latestRecord = latest;
          _recentChartRecords = recent;
          _chartSpots = spots;
          _isLoadingBloodSugar = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingBloodSugar = false);
      }
    }
  }

  String _getBloodSugarStatusText(int value, String measureType) {
    if (measureType == '공복' || measureType == '식전') {
      if (value < 100) return '정상 범위 내에 있습니다';
      if (value < 126) return '공복혈당장애 주의가 필요해요';
      return '혈당 관리가 필요해요';
    } else {
      if (value < 140) return '정상 범위 내에 있습니다';
      if (value < 200) return '내당능장애 주의가 필요해요';
      return '혈당 관리가 필요해요';
    }
  }

  Color _getCardColor(int value, String measureType) {
    if (measureType == '공복' || measureType == '식전') {
      if (value < 100) return const Color(0xFF2F69FE);
      if (value < 126) return Colors.orangeAccent;
      return Colors.redAccent;
    } else {
      if (value < 140) return const Color(0xFF2F69FE);
      if (value < 200) return Colors.orangeAccent;
      return Colors.redAccent;
    }
  }

  Future<void> _pickImageAndAnalyze({
    required BuildContext context,
    required Future<XFile?> Function() pickImage,
    bool fromBottomSheet = true,
  }) async {
    if (fromBottomSheet) {
      Navigator.pop(context);
    }

    final XFile? image = await pickImage();

    if (image == null || !mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final mealAiService = MealAiService();

      final mealRecord = await mealAiService.analyzeFoodImage(
        image: image,
        mealType: '식사',
        dateTime: DateTime.now(),
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      final action = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AnalysisResultPage(image: image, result: mealRecord.toJson()),
        ),
      );

      if (action == 'retake' && mounted) {
        Future.microtask(() {
          _pickImageAndAnalyze(
            context: context,
            pickImage: pickImage,
            fromBottomSheet: false,
          );
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('분석 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDietCaptureBottomSheet(BuildContext context) {
    final ImagePickerService imagePickerService = ImagePickerService();
    final parentContext = context;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        final textTheme = Theme.of(context).textTheme;
        final colorScheme = Theme.of(context).colorScheme;

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () async {
                  await _pickImageAndAnalyze(
                    context: parentContext,
                    pickImage: imagePickerService.pickFromCamera,
                  );
                },
                icon: Icon(
                  Icons.camera_alt,
                  color: colorScheme.onPrimary,
                  size: 24,
                ),
                label: Text(
                  '카메라로 촬영하기',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: () async {
                  await _pickImageAndAnalyze(
                    context: parentContext,
                    pickImage: imagePickerService.pickFromGallery,
                  );
                },
                icon: Icon(
                  Icons.image_outlined,
                  color: colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                label: Text(
                  '갤러리에서 선택하기',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final latestRecord = _latestRecord;
    final int currentValue = latestRecord?.bloodSugar ?? 0;
    final String currentType = latestRecord?.mealState ?? '공복';

    final Color cardBackgroundColor = latestRecord != null
        ? _getCardColor(currentValue, currentType)
        : const Color(0xFFF3F4F6);

    final String displayValue = currentValue > 0
        ? currentValue.toString()
        : '-';
    final String statusMessage = currentValue > 0
        ? _getBloodSugarStatusText(currentValue, currentType)
        : '아직 기록이 없습니다';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                pinned: false,
                backgroundColor: colorScheme.surface,
                surfaceTintColor: colorScheme.surface,
                toolbarHeight: 90,
                automaticallyImplyLeading: false,
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '안녕하세요, $_userName님!',
                            style: textTheme.headlineMedium?.copyWith(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '오늘도 건강한 하루 되세요.',
                            style: textTheme.bodyMedium?.copyWith(
                              fontSize: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyPage(),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: const Color(0xFFE8F0FE),
                        child: Text(
                          _userInitial,
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomCard(
                        padding: const EdgeInsets.all(25),
                        borderRadius: 25,
                        backgroundColor: cardBackgroundColor,
                        showShadow: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF5B8EFF),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '최근 혈당',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.trending_up,
                                  color: colorScheme.onPrimary,
                                  size: 20,
                                ),
                              ],
                            ),
                            const SizedBox(height: 25),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  displayValue,
                                  style: textTheme.displayMedium?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontSize: 56,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'mg/dL',
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              currentValue > 0
                                  ? '✓ $statusMessage ($currentType)'
                                  : '측정을 시작해보세요!',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onPrimary.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          Expanded(
                            child: CustomCard(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const BloodSugarAddPage(),
                                  ),
                                );
                                _loadHomeBloodSugarData();
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomIcon(
                                    icon: Icons.add,
                                    backgroundColor: const Color(0xFFE8F0FE),
                                    iconColor: colorScheme.primary,
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    '혈당 기록',
                                    style: textTheme.bodyLarge?.copyWith(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: CustomCard(
                              onTap: () {
                                _showDietCaptureBottomSheet(context);
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomIcon(
                                    icon: Icons.camera_alt_outlined,
                                    backgroundColor: const Color(0xFFE8FAF1),
                                    iconColor: const Color(0xFF12B76A),
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    '식단 촬영',
                                    style: textTheme.bodyLarge?.copyWith(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 35),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '혈당 리포트',
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const BloodSugarAnalysisScreen(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  '자세히 보기',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          CustomCard(
                            child: SizedBox(
                              height: 150,
                              width: double.infinity,
                              child: Center(
                                child: _isLoadingBloodSugar
                                    ? const CircularProgressIndicator()
                                    : _recentChartRecords.isEmpty
                                    ? const Text(
                                        '아직 기록된 혈당이 없어요!',
                                        style: TextStyle(color: Colors.grey),
                                      )
                                    : BloodGlucoseLineChart(
                                        chartSpots: _chartSpots,
                                        sortedRecords: _recentChartRecords,
                                        selectedIndex: 1,
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
            ],
          ),
        ),
      ),
    );
  }
}
