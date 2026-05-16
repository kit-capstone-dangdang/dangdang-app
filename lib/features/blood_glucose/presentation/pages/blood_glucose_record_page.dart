import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dangdang/core/widgets/common/custom_icon.dart';
import 'package:dangdang/core/widgets/common/state_views.dart';
import 'package:dangdang/core/widgets/common/ai_analysis_bottom_sheet.dart';
import 'package:dangdang/core/widgets/filter/ai_analysis_button.dart';
import 'package:dangdang/core/widgets/filter/record_category_tabs.dart';
import 'package:dangdang/core/widgets/filter/record_range_dropdown.dart';
import 'package:dangdang/core/widgets/filter/record_range_filter_card.dart';
import 'package:dangdang/features/blood_glucose/domain/entities/blood_glucose_record.dart';
import 'package:dangdang/features/blood_glucose/domain/entities/blood_glucose_analysis_result.dart';
import 'package:dangdang/features/blood_glucose/data/repositories/firebase_blood_glucose_repository.dart';
import 'package:dangdang/features/blood_glucose/presentation/pages/blood_glucose_analysis_page.dart';
import 'package:dangdang/features/blood_glucose/presentation/pages/blood_glucose_add_page.dart';
import 'package:dangdang/features/blood_glucose/presentation/pages/blood_glucose_edit_page.dart';
import 'package:dangdang/features/blood_glucose/presentation/widgets/blood_glucose_record_card.dart';
import 'package:dangdang/features/blood_glucose/data/services/blood_glucose_ai_service.dart';
import 'package:dangdang/features/meal/presentation/widgets/date_header.dart';
import 'package:dangdang/features/meal/presentation/widgets/ai_analysis_card.dart';

enum _BloodSugarRecordRange {
  all('전체 기록'),
  today('오늘 기록'),
  last7Days('최근 7일'),
  last15Days('최근 15일'),
  last30Days('최근 30일');

  const _BloodSugarRecordRange(this.label);
  final String label;
}

class BloodSugarRecordPage extends StatefulWidget {
  const BloodSugarRecordPage({super.key});

  @override
  State<BloodSugarRecordPage> createState() => _BloodSugarRecordPageState();
}

class _BloodSugarRecordPageState extends State<BloodSugarRecordPage> {
  final repository = FirebaseBloodSugarRepository();
  final _aiService = BloodGlucoseAIService();

  List<BloodGlucoseRecord> records = [];
  bool isLoading = true;

  bool _isRangeExpanded = false;
  _BloodSugarRecordRange _selectedRange = _BloodSugarRecordRange.all;
  String _selectedTimeFilter = '전체';

  static const List<String> _timeFilters = ['전체', '공복', '식전', '식후', '취침전'];

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final GlobalKey _dropdownKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    loadRecords();
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  Future<void> loadRecords() async {
    setState(() => isLoading = true);

    try {
      final data = await repository.getRecords();
      data.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      setState(() {
        records = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _showAiAnalysisBottomSheet(List<BloodGlucoseRecord> targetRecords) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return AiAnalysisBottomSheet<BloodGlucoseAnalysisResult>(
          title: 'AI 맞춤 혈당 리포트',
          subtitle: '필터: ${_selectedRange.label} · $_selectedTimeFilter',
          loadingMessage: 'AI 혈당 분석중입니다...',
          analysisFuture: _aiService.analyzeBloodSugarHabits(
            records: targetRecords,
            rangeLabel: _selectedRange.label,
            timeFilter: _selectedTimeFilter,
          ),
          analysisBuilder: (context, result) {
            final patterns = result.patterns.isEmpty
                ? const ['조건에 맞는 기록이 부족하여 패턴을 찾지 못했어요.']
                : result.patterns;
            final recommendations = result.recommendations.isEmpty
                ? const ['기록이 더 쌓이면 구체적인 관리 추천을 드릴 수 있어요.']
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
                      '혈당 패턴',
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
                      Icons.favorite_outline_rounded,
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

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(int value, String measureType) {
    if (measureType == '공복' || measureType == '식전') {
      if (value < 100) return const Color(0xFF2F69FE);
      if (value < 126) return Colors.orange;
      return const Color(0xFFFF4B4B);
    } else {
      if (value < 140) return const Color(0xFF2F69FE);
      if (value < 200) return Colors.orange;
      return const Color(0xFFFF4B4B);
    }
  }

  List<BloodGlucoseRecord> get filteredRecords {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return records.where((record) {
      final target = DateTime(
        record.dateTime.year,
        record.dateTime.month,
        record.dateTime.day,
      );
      final difference = today.difference(target).inDays;

      if (difference < 0) return false;

      final rangeMatched = switch (_selectedRange) {
        _BloodSugarRecordRange.all => true,
        _BloodSugarRecordRange.today => difference == 0,
        _BloodSugarRecordRange.last7Days => difference < 7,
        _BloodSugarRecordRange.last15Days => difference < 15,
        _BloodSugarRecordRange.last30Days => difference < 30,
      };

      final timeMatched =
          _selectedTimeFilter == '전체' ||
          record.mealState == _selectedTimeFilter;

      return rangeMatched && timeMatched;
    }).toList();
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
                child: RecordRangeDropdown<_BloodSugarRecordRange>(
                  values: _BloodSugarRecordRange.values,
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

  @override
  Widget build(BuildContext context) {
    final visibleRecords = filteredRecords;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2962FF),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BloodSugarAddPage()),
          );
          await loadRecords();
        },
        child: const Icon(Icons.add, color: Colors.white, size: 34),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: false,
              snap: true,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              toolbarHeight: 86,
              titleSpacing: 24,
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      '혈당 기록',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                    ),
                  ),
                  AiAnalysisButton(
                    label: 'AI 건강 분석',
                    onTap: () => _showAiAnalysisBottomSheet(visibleRecords),
                  ),
                  const SizedBox(width: 10),
                  CustomIcon(
                    icon: Icons.show_chart_rounded,
                    size: 58,
                    backgroundColor: const Color(0xFFF3F4F6),
                    iconColor: const Color(0xFF6B7280),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BloodSugarAnalysisScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CompositedTransformTarget(
                      link: _layerLink,
                      child: KeyedSubtree(
                        key: _dropdownKey,
                        child: RecordRangeFilterCard(
                          label: _selectedRange.label,
                          isExpanded: _isRangeExpanded,
                          onTap: _toggleDropdown,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    RecordCategoryTabs(
                      categories: _timeFilters,
                      selectedCategory: _selectedTimeFilter,
                      onSelected: (timeFilter) {
                        setState(() {
                          _selectedTimeFilter = timeFilter;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: isLoading
                  ? const SizedBox(height: 200, child: LoadingView())
                  : records.isEmpty
                  ? const EmptyStateView(
                      message: "아직 혈당 기록이 없어요\n첫 혈당 기록을 추가해보세요",
                    )
                  : visibleRecords.isEmpty
                  ? _buildFilteredEmptyState()
                  : _buildRecordList(visibleRecords),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredEmptyState() {
    return SizedBox(
      height: 300,
      child: Center(
        child: Text(
          '조건에 맞는 혈당 기록이 없어요',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildRecordList(List<BloodGlucoseRecord> visibleRecords) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(visibleRecords.length, (index) {
          final record = visibleRecords[index];
          bool showDateHeader = false;

          if (index == 0) {
            showDateHeader = true;
          } else {
            final prevDate = _formatDate(visibleRecords[index - 1].dateTime);
            final currDate = _formatDate(record.dateTime);

            if (prevDate != currDate) {
              showDateHeader = true;
            }
          }

          final Color themeColor = _getStatusColor(
            record.bloodSugar,
            record.mealState,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showDateHeader) ...[
                if (index > 0) const SizedBox(height: 32),
                DateHeader(date: _formatDate(record.dateTime)),
                const SizedBox(height: 16),
              ],
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Theme(
                  data: Theme.of(context).copyWith(primaryColor: themeColor),
                  child: BloodGlucoseRecordCard(
                    record: record,
                    onEdit: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BloodGlucoseEditPage(record: record),
                        ),
                      );
                      await loadRecords();
                    },
                    onDelete: () => _handleDelete(record),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Future<void> _handleDelete(BloodGlucoseRecord record) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          '혈당 기록 삭제',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('이 혈당 기록을 정말 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              '취소',
              style: TextStyle(
                color: Color(0xFF6B7384),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '삭제',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmDelete == true && mounted) {
      try {
        await repository.deleteRecord(record.id);

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('성공적으로 삭제되었습니다.')));
        }
        await loadRecords();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('삭제 중 오류가 발생했습니다.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
