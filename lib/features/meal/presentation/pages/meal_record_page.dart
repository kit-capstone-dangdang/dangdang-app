import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dangdang/core/widgets/common/state_views.dart';
import 'package:dangdang/core/widgets/common/ai_analysis_bottom_sheet.dart';
import 'package:dangdang/core/widgets/filter/ai_analysis_button.dart';
import 'package:dangdang/core/widgets/filter/record_category_tabs.dart';
import 'package:dangdang/core/widgets/filter/record_range_dropdown.dart';
import 'package:dangdang/core/widgets/filter/record_range_filter_card.dart';
import 'package:dangdang/features/meal/data/repositories/firebase_meal_repository.dart';
import 'package:dangdang/features/meal/data/services/image_picker_service.dart';
import 'package:dangdang/features/meal/data/services/meal_ai_service.dart';
import 'package:dangdang/features/meal/domain/entities/meal_record.dart';
import 'package:dangdang/features/meal/presentation/pages/analysis_result_page.dart';
import 'package:dangdang/features/meal/presentation/pages/food_edit_page.dart';
import 'package:dangdang/features/meal/presentation/pages/meal_analysis_result_page.dart';
import 'package:dangdang/features/meal/presentation/widgets/ai_analysis_card.dart';
import 'package:dangdang/features/meal/presentation/widgets/date_header.dart';
import 'package:dangdang/features/meal/presentation/widgets/meal_record_card.dart';
import 'package:dangdang/core/widgets/common/image_source_bottom_sheet.dart';

class MealRecordPage extends StatefulWidget {
  const MealRecordPage({super.key});

  @override
  State<MealRecordPage> createState() => _MealRecordPageState();
}

class _MealRecordPageState extends State<MealRecordPage> {
  static const List<String> _mealFilters = ['전체', '아침', '점심', '저녁', '야식'];

  bool _isLoading = false;
  bool _isRangeExpanded = false;
  _MealRecordRange _selectedRange = _MealRecordRange.all;
  String _selectedMealFilter = '전체';

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final GlobalKey _dropdownKey = GlobalKey();

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _foodNames(List<MealRecord> records, int index) {
    return records[index].foods.map((food) => food.name).join(', ');
  }

  int _totalCalories(MealRecord record) {
    return (record.totalNutrition['calories'] ?? 0).round();
  }

  bool _matchesSelectedRange(DateTime dateTime) {
    if (_selectedRange == _MealRecordRange.all) {
      return true;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final difference = today.difference(target).inDays;

    if (difference < 0) {
      return false;
    }

    switch (_selectedRange) {
      case _MealRecordRange.all:
        return true;
      case _MealRecordRange.today:
        return difference == 0;
      case _MealRecordRange.last7Days:
        return difference < 7;
      case _MealRecordRange.last15Days:
        return difference < 15;
      case _MealRecordRange.last30Days:
        return difference < 30;
    }
  }

  List<MealRecord> _applyFilters(List<MealRecord> records) {
    return records.where((record) {
      final matchesRange = _matchesSelectedRange(record.dateTime);
      final matchesMeal =
          _selectedMealFilter == '전체' || record.mealType == _selectedMealFilter;

      return matchesRange && matchesMeal;
    }).toList();
  }

  String _analysisSubtitle() {
    return '필터: ${_selectedRange.label} · $_selectedMealFilter';
  }

  Future<String> _loadDiabetesType() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return '2형';
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    return snapshot.data()?['diabetesType']?.toString() ?? '2형';
  }

  Future<MealHabitAnalysisResult> _analyzeMealHabits({
    required List<MealRecord> records,
    required String subtitle,
  }) async {
    final diabetesType = await _loadDiabetesType();

    return MealAiService().analyzeMealHabits(
      records: records,
      scopeLabel: subtitle,
      diabetesType: diabetesType,
    );
  }

  void _showEmptyAnalysisSnackBar() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('분석할 식단 기록이 아직 없어요.')));
  }

  void _showAiAnalysisBottomSheet(List<MealRecord> records) {
    if (records.isEmpty) {
      _showEmptyAnalysisSnackBar();
      return;
    }

    final subtitle = _analysisSubtitle();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AiAnalysisBottomSheet<dynamic>(
          title: 'AI 식단 건강 리포트',
          subtitle: subtitle,
          loadingMessage: 'AI 식단 분석중입니다...',
          analysisFuture: _analyzeMealHabits(
            records: records,
            subtitle: subtitle,
          ),
          analysisBuilder: (context, result) {
            final patterns = result.patterns.isEmpty
                ? const ['기록된 식단 수가 적어 뚜렷한 패턴을 찾지 못했어요.']
                : result.patterns;
            final recommendations = result.recommendations.isEmpty
                ? const ['기록이 더 쌓이면 더 구체적인 식단 추천을 드릴 수 있어요.']
                : result.recommendations;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      color: Color(0xFF5A46F5),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '식습관 패턴',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...patterns.map(
                  (pattern) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AiAnalysisCard(
                      text: pattern,
                      icon: Icons.circle,
                      iconColor: const Color(0xFFB180FA),
                      backgroundColor: const Color(0xFFF6F0FF),
                      borderColor: const Color(0xFFEFE6FF),
                      textColor: const Color(0xFF34177A),
                      iconSize: 8,
                      isPattern: true,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    const Icon(
                      Icons.restaurant_outlined,
                      color: Color(0xFF3CB043),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI 추천',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...recommendations.map(
                  (recommendation) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AiAnalysisCard(
                      text: recommendation,
                      icon: Icons.check_circle_outline_rounded,
                      iconColor: const Color(0xFF4CB158),
                      backgroundColor: const Color(0xFFF9FFFA),
                      borderColor: const Color(0xFFE5F7E8),
                      textColor: const Color(0xFF1B4021),
                      iconSize: 22,
                      isPattern: false,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
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
        return ImageSourceBottomSheet(
          onCameraTap: () async {
            await _pickImageAndAnalyze(
              context: parentContext,
              pickImage: imagePickerService.pickFromCamera,
            );
          },
          onGalleryTap: () async {
            await _pickImageAndAnalyze(
              context: parentContext,
              pickImage: imagePickerService.pickFromGallery,
            );
          },
        );
      },
    );
  }

  void _closeDropdown() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }

    if (mounted) {
      setState(() {
        _isRangeExpanded = false;
      });
    }
  }

  void _openDropdown() {
    final renderBox =
        _dropdownKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) return;

    final size = renderBox.size;

    setState(() {
      _isRangeExpanded = true;
    });

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeDropdown,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + 12),
            child: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: size.width,
                child: RecordRangeDropdown<_MealRecordRange>(
                  values: _MealRecordRange.values,
                  selectedValue: _selectedRange,
                  labelBuilder: (range) => range.label,
                  onSelected: (range) {
                    setState(() {
                      _selectedRange = range;
                    });
                    _closeDropdown();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _toggleDropdown() {
    if (_isRangeExpanded) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  Widget _buildTopHeader(List<MealRecord> filteredRecords) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            '식단 기록',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        AiAnalysisButton(
          label: 'AI 건강 분석',
          onTap: () => _showAiAnalysisBottomSheet(filteredRecords),
        ),
      ],
    );
  }

  Widget _buildRangeFilterCard() {
    return CompositedTransformTarget(
      link: _layerLink,
      child: KeyedSubtree(
        key: _dropdownKey,
        child: RecordRangeFilterCard(
          label: _selectedRange.label,
          isExpanded: _isRangeExpanded,
          onTap: _toggleDropdown,
        ),
      ),
    );
  }

  Widget _buildMealTabs() {
    return RecordCategoryTabs(
      categories: _mealFilters,
      selectedCategory: _selectedMealFilter,
      onSelected: (mealFilter) {
        setState(() {
          _selectedMealFilter = mealFilter;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final repository = FirebaseMealRepository();

    return Scaffold(
      backgroundColor: Colors.white,
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SafeArea(
          child: Stack(
            children: [
              StreamBuilder<List<MealRecord>>(
                stream: repository.watchMeals(),
                builder: (context, snapshot) {
                  final records = <MealRecord>[
                    ...(snapshot.data ?? const <MealRecord>[]),
                  ]..sort((a, b) => b.dateTime.compareTo(a.dateTime));

                  final filteredRecords = _applyFilters(records);

                  return CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        floating: true,
                        pinned: false,
                        snap: true,
                        automaticallyImplyLeading: false,
                        backgroundColor: Colors.white,
                        surfaceTintColor: Colors.white,
                        toolbarHeight: 82,
                        titleSpacing: 24,
                        title: _buildTopHeader(filteredRecords),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildRangeFilterCard(),
                              const SizedBox(height: 16),
                              _buildMealTabs(),
                            ],
                          ),
                        ),
                      ),
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          records.isEmpty)
                        const SliverFillRemaining(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF5A46F5),
                            ),
                          ),
                        )
                      else if (snapshot.hasError)
                        const SliverFillRemaining(
                          child: Center(child: Text('식단 기록을 불러오지 못했습니다.')),
                        )
                      else if (filteredRecords.isEmpty)
                        SliverFillRemaining(
                          child: Center(
                            child: Text(
                              '조건에 맞는 식단 기록이 아직 없어요.',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF3E4657),
                                  ),
                            ),
                          ),
                        )
                      else
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(filteredRecords.length, (
                                index,
                              ) {
                                final record = filteredRecords[index];
                                bool showDateHeader = false;

                                if (index == 0) {
                                  showDateHeader = true;
                                } else {
                                  final prevDate = _formatDate(
                                    filteredRecords[index - 1].dateTime,
                                  );
                                  final currDate = _formatDate(record.dateTime);

                                  if (prevDate != currDate) {
                                    showDateHeader = true;
                                  }
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (showDateHeader) ...[
                                      if (index > 0) const SizedBox(height: 32),
                                      DateHeader(
                                        date: _formatDate(record.dateTime),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 25,
                                      ),
                                      child: MealRecordCard(
                                        mealType: record.mealType,
                                        time: _formatTime(record.dateTime),
                                        calories: _totalCalories(record),
                                        foodName: _foodNames(
                                          filteredRecords,
                                          index,
                                        ),
                                        itemCount: record.foods.length,
                                        imageUrl: record.imageUrl,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  MealAnalysisResultPage(
                                                    record: record,
                                                  ),
                                            ),
                                          );
                                        },
                                        onEdit: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => FoodEditPage(
                                                originalRecord: record,
                                              ),
                                            ),
                                          );
                                        },
                                        onDelete: () async {
                                          final bool? confirmDelete =
                                              await showDialog<bool>(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    backgroundColor:
                                                        Colors.white,
                                                    title: const Text('식단 삭제'),
                                                    content: const Text(
                                                      '이 식단 기록을 정말 삭제하시겠습니까?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                              false,
                                                            ),
                                                        child: const Text(
                                                          '취소',
                                                          style: TextStyle(
                                                            color: Color(
                                                              0xFF6B7384,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                              true,
                                                            ),
                                                        child: const Text(
                                                          '삭제',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );

                                          if (confirmDelete == true &&
                                              context.mounted) {
                                            try {
                                              await repository.deleteMeal(
                                                record.id,
                                                imageUrl: record.imageUrl,
                                              );

                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      '성공적으로 삭제되었습니다.',
                                                    ),
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      '삭제 중 오류가 발생했습니다.',
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              Positioned(
                right: 20,
                bottom: 20,
                child: FloatingActionButton(
                  onPressed: () {
                    _showDietCaptureBottomSheet(context);
                  },
                  backgroundColor: const Color(0xFF4CB158),
                  shape: const CircleBorder(),
                  elevation: 6,
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                    size: 28,
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

enum _MealRecordRange {
  all('전체 기록'),
  today('오늘 식단'),
  last7Days('최근 7일'),
  last15Days('최근 15일'),
  last30Days('최근 30일');

  const _MealRecordRange(this.label);

  final String label;
}
