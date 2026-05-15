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

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}';
  }

  Future<void> loadRecords() async {
    final data = await repository.getRecords();

    setState(() {
      records = data;
    });
  }

  @override
  void initState() {
    super.initState();
    loadRecords();
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
              child: records.isEmpty
                  ? SizedBox(
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
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              '우측 상단 + 버튼으로\n첫 혈당 기록을 추가해보세요',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey.shade500,
                                    height: 1.5,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(records.length, (index) {
                          final record = records[index];

                          bool showDateHeader = false;

                          if (index == 0) {
                            showDateHeader = true;
                          } else {
                            final prevDate = _formatDate(
                              records[index - 1].dateTime,
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

                                DateHeader(date: _formatDate(record.dateTime)),

                                const SizedBox(height: 16),
                              ],

                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: BloodSugarRecordCard(
                                  record: record,
                                  onEdit: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            BloodSugarEditPage(record: record),
                                      ),
                                    );

                                    await loadRecords();
                                  },
                                  onDelete: () async {
                                    final bool?
                                    confirmDelete = await showDialog<bool>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: Colors.white,

                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                          ),

                                          title: const Text(
                                            '혈당 기록 삭제',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),

                                          content: const Text(
                                            '이 혈당 기록을 정말 삭제하시겠습니까?',
                                            style: TextStyle(
                                              fontSize: 15,
                                              height: 1.5,
                                            ),
                                          ),

                                          actionsPadding: const EdgeInsets.only(
                                            left: 16,
                                            right: 16,
                                            bottom: 14,
                                          ),

                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),

                                              child: const Text(
                                                '취소',
                                                style: TextStyle(
                                                  color: Color(0xFF6B7384),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),

                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),

                                              child: const Text(
                                                '삭제',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
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
                                        await repository.deleteRecord(
                                          record.id,
                                        );

                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text('성공적으로 삭제되었습니다.'),
                                            ),
                                          );
                                        }

                                        await loadRecords();
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text('삭제 중 오류가 발생했습니다.'),
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
        ),
      ),
    );
  }
}
