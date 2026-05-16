import 'package:flutter/material.dart';
import 'package:dangdang/core/widgets/common/custom_icon.dart';
import 'package:dangdang/features/blood_glucose/domain/entities/blood_sugar_record.dart';
import 'package:dangdang/features/blood_glucose/domain/repositories/firebase_blood_sugar_repository.dart';
import 'package:dangdang/features/blood_glucose/presentation/pages/blood_glucose_analysis_page.dart';
import 'package:dangdang/features/blood_glucose/presentation/pages/blood_sugar_add_page.dart';
import 'package:dangdang/features/blood_glucose/presentation/pages/blood_sugar_edit_page.dart';
import 'package:dangdang/features/blood_glucose/presentation/widgets/blood_sugar_record_card.dart';
import 'package:dangdang/features/meal/presentation/widgets/date_header.dart';

class BloodSugarRecordPage extends StatefulWidget {
  const BloodSugarRecordPage({super.key});

  @override
  State<BloodSugarRecordPage> createState() => _BloodSugarRecordPageState();
}

class _BloodSugarRecordPageState extends State<BloodSugarRecordPage> {
  final repository = FirebaseBloodSugarRepository();
  List<BloodSugarRecord> records = [];
  bool isLoading = true;

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}';
  }

  Future<void> loadRecords() async {
    setState(() => isLoading = true);
    try {
      final data = await repository.getRecords();

      data.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      final recentData = data.take(4).toList();

      setState(() {
        records = recentData;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    loadRecords();
  }

  // 💡 혈당 수치와 타이밍(식전/식후)에 따라 정확한 색상을 반환하는 마법의 함수!
  Color _getStatusColor(int value, String measureType) {
    if (measureType == '공복' || measureType == '식전') {
      if (value < 100) return const Color(0xFF2F69FE); // 정상: 파랑
      if (value < 126) return Colors.orange; // 주의: 주황
      return const Color(0xFFFF4B4B); // 위험: 빨강
    } else {
      if (value < 140) return const Color(0xFF2F69FE); // 정상: 파랑
      if (value < 200) return Colors.orange; // 주의: 주황
      return const Color(0xFFFF4B4B); // 위험: 빨강
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              toolbarHeight: 70,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '혈당 기록',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    children: [
                      CustomIcon(
                        icon: Icons.show_chart_rounded,
                        size: 52,
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
                      const SizedBox(width: 10),
                      CustomIcon(
                        icon: Icons.add,
                        size: 52,
                        backgroundColor: const Color(0xFF2962FF),
                        iconColor: Colors.white,
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BloodSugarAddPage(),
                            ),
                          );
                          await loadRecords();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: isLoading
                  ? const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : records.isEmpty
                  ? _buildEmptyState()
                  : _buildRecordList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.monitor_heart_outlined,
              size: 72,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 20),
            Text(
              '아직 혈당 기록이 없어요',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '우측 상단 + 버튼으로\n첫 혈당 기록을 추가해보세요',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordList() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(records.length, (index) {
          final record = records[index];
          bool showDateHeader = false;

          if (index == 0) {
            showDateHeader = true;
          } else {
            final prevDate = _formatDate(records[index - 1].dateTime);
            final currDate = _formatDate(record.dateTime);
            if (prevDate != currDate) showDateHeader = true;
          }

          // 💡 여기서 개별 기록마다 알맞은 테마 색상을 뽑아냅니다!
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
                  // 💡 중요: 개별 카드 내부에서 이 색상을 'Theme.of(context).primaryColor' 등으로
                  // 쉽게 땡겨서 쓸 수 있도록 테마로 감싸서 전달해 줍니다!
                  data: Theme.of(context).copyWith(primaryColor: themeColor),
                  child: BloodSugarRecordCard(
                    record: record,
                    onEdit: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BloodSugarEditPage(record: record),
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

  Future<void> _handleDelete(BloodSugarRecord record) async {
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
