import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dangdang/core/widgets/common/state_views.dart';
import 'package:dangdang/features/meal/data/repositories/firebase_meal_repository.dart';
import 'package:dangdang/features/meal/data/services/image_picker_service.dart';
import 'package:dangdang/features/meal/data/services/meal_ai_service.dart';
import 'package:dangdang/features/meal/domain/entities/meal_record.dart';
import 'package:dangdang/features/meal/presentation/pages/analysis_result_page.dart';
import 'package:dangdang/features/meal/presentation/pages/food_edit_page.dart';
import 'package:dangdang/features/meal/presentation/pages/meal_analysis_result_page.dart';
import 'package:dangdang/features/meal/presentation/widgets/date_header.dart';
import 'package:dangdang/features/meal/presentation/widgets/meal_record_card.dart';
import 'package:dangdang/features/meal/presentation/widgets/ai_analysis_bottom_sheet.dart';

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

  String _normalizeMealType(String mealType) {
    final normalized = mealType.trim().toLowerCase();

    if (normalized.contains('아침') ||
        normalized.contains('조식') ||
        normalized.contains('breakfast')) {
      return '아침';
    }
    if (normalized.contains('점심') ||
        normalized.contains('중식') ||
        normalized.contains('lunch')) {
      return '점심';
    }
    if (normalized.contains('저녁') ||
        normalized.contains('석식') ||
        normalized.contains('dinner')) {
      return '저녁';
    }
    if (normalized.contains('야식') ||
        normalized.contains('snack') ||
        normalized.contains('night')) {
      return '야식';
    }

    return mealType.trim();
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
          _selectedMealFilter == '전체' ||
          _normalizeMealType(record.mealType) == _selectedMealFilter ||
          record.mealType == _selectedMealFilter;

      return matchesRange && matchesMeal;
    }).toList();
  }

  String _analysisSubtitle() {
    if (_selectedRange == _MealRecordRange.all && _selectedMealFilter == '전체') {
      return '전체 기간 식사 패턴 분석';
    }

    if (_selectedMealFilter == '전체') {
      return '${_selectedRange.label} 식사 패턴 분석';
    }

    return '${_selectedRange.label} · $_selectedMealFilter 패턴 분석';
  }

  void _showEmptyAnalysisSnackBar() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('분석할 식단 기록이 아직 없어요.')));
  }

  Future<void> _showAiAnalysisBottomSheet(List<MealRecord> records) async {
    if (records.isEmpty) {
      _showEmptyAnalysisSnackBar();
      return;
    }

    final subtitle = _analysisSubtitle();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AiAnalysisBottomSheet(records: records, subtitle: subtitle);
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
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
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
                icon: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 24,
                ),
                label: const Text(
                  '카메라로 촬영하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
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
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                label: Text(
                  '갤러리에서 선택하기',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
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
              child: Container(
                width: size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF3F4F7)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _MealRecordRange.values.map((range) {
                    final isSelected = range == _selectedRange;
                    return InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        setState(() {
                          _selectedRange = range;
                        });
                        _closeDropdown();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                range.label,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? const Color(0xFF5A46F5)
                                          : const Color(0xFF4D5566),
                                    ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_rounded,
                                color: Color(0xFF5A46F5),
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
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
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5AFF), Color(0xFF9F7AEA)],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5AFF).withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: () => _showAiAnalysisBottomSheet(filteredRecords),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'AI 건강 분석',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRangeFilterCard() {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: _dropdownKey,
          borderRadius: BorderRadius.circular(24),
          onTap: _toggleDropdown,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF3F4F7)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: Color(0xFF5A46F5),
                  size: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    _selectedRange.label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF26324B),
                    ),
                  ),
                ),
                Icon(
                  _isRangeExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.chevron_right_rounded,
                  color: const Color(0xFF9AA1B4),
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMealTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _mealFilters.map((mealFilter) {
          final isSelected = mealFilter == _selectedMealFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  setState(() {
                    _selectedMealFilter = mealFilter;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF5A46F5) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : const Color(0xFFF3F4F7),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF5A46F5).withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Text(
                    mealFilter,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF6B7384),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
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
