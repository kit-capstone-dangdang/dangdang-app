<<<<<<< HEAD
import 'package:dangdang/features/blood_glucose/data/datasources/blood_sugar_dummy_data.dart';
=======
import 'package:dangdang/core/widgets/common/custom_icon.dart';
import 'package:dangdang/features/blood_glucose/domain/entities/blood_sugar_record.dart';
import 'package:dangdang/features/blood_glucose/domain/repositories/firebase_blood_sugar_repository.dart';
>>>>>>> 77c1b8faec2c030f2e4f6eb4c5b9b17531e0e916
import 'package:dangdang/features/blood_glucose/presentation/pages/blood_glucose_analysis_page.dart';
import 'package:dangdang/features/blood_glucose/presentation/pages/blood_sugar_add_page.dart';
import 'package:dangdang/features/blood_glucose/presentation/pages/blood_sugar_edit_page.dart';
import 'package:dangdang/features/blood_glucose/presentation/widgets/blood_sugar_record_card.dart';
import 'package:dangdang/features/blood_glucose/domain/entities/blood_sugar_record.dart';
import 'package:dangdang/features/meal/presentation/widgets/date_header.dart';
import 'package:flutter/material.dart';

<<<<<<< HEAD
// 💡 1. StatelessWidget에서 StatefulWidget으로 변경!
=======
>>>>>>> 77c1b8faec2c030f2e4f6eb4c5b9b17531e0e916
class BloodSugarRecordPage extends StatefulWidget {
  const BloodSugarRecordPage({super.key});

  @override
<<<<<<< HEAD
  State<BloodSugarRecordPage> createState() => _BloodSugarRecordPageState();
}

class _BloodSugarRecordPageState extends State<BloodSugarRecordPage> {
=======
  State<BloodSugarRecordPage> createState() =>
      _BloodSugarRecordPageState();
}

class _BloodSugarRecordPageState
    extends State<BloodSugarRecordPage> {
  final repository = FirebaseBloodSugarRepository();

  List<BloodSugarRecord> records = [];

>>>>>>> 77c1b8faec2c030f2e4f6eb4c5b9b17531e0e916
  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}';
  }

<<<<<<< HEAD
  // 💡 데이터가 변경되었을 때 화면을 다시 그리기 위한 함수
  void _refreshList() {
    setState(() {});
=======
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
>>>>>>> 77c1b8faec2c030f2e4f6eb4c5b9b17531e0e916
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    // build가 실행될 때마다(setState 호출 시) 최신 더미데이터를 다시 불러옵니다.
    final records = dummyBloodSugarRecords;

=======
>>>>>>> 77c1b8faec2c030f2e4f6eb4c5b9b17531e0e916
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
<<<<<<< HEAD
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '혈당 기록',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
=======
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '혈당 기록',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
>>>>>>> 77c1b8faec2c030f2e4f6eb4c5b9b17531e0e916
                  ),
                  Row(
                    children: [
                      CustomIcon(
                        icon: Icons.show_chart_rounded,
                        size: 52,
                        backgroundColor:
                            const Color(0xFFF3F4F6),
                        iconColor:
                            const Color(0xFF6B7280),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const BloodSugarAnalysisScreen(),
                            ),
                          );
                        },
                      ),
<<<<<<< HEAD
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.add_box,
                          size: 28,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          // 💡 2. 데이터 추가 후 돌아오면 _refreshList를 실행하여 새로고침!
                          Navigator.push(
=======

                      const SizedBox(width: 10),

                      CustomIcon(
                        icon: Icons.add,
                        size: 52,
                        backgroundColor:
                            const Color(0xFF2962FF),
                        iconColor: Colors.white,
                        onPressed: () async {
                          await Navigator.push(
>>>>>>> 77c1b8faec2c030f2e4f6eb4c5b9b17531e0e916
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const BloodSugarAddPage(),
                            ),
<<<<<<< HEAD
                          ).then((_) => _refreshList());
=======
                          );

                          await loadRecords();
>>>>>>> 77c1b8faec2c030f2e4f6eb4c5b9b17531e0e916
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
<<<<<<< HEAD
              child: Padding(
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
                            onEdit: () {
                              // 💡 3. 데이터 수정 후 돌아오면 _refreshList를 실행하여 새로고침!
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      BloodSugarEditPage(record: record),
                                ),
                              ).then((_) => _refreshList());
                            },
                          ),
=======
              child: records.isEmpty
                  ? SizedBox(
                      height:
                          MediaQuery.of(context)
                                  .size
                                  .height *
                              0.7,
                      child: Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons
                                  .monitor_heart_outlined,
                              size: 72,
                              color:
                                  Colors.grey.shade300,
                            ),

                            const SizedBox(height: 20),

                            Text(
                              '아직 혈당 기록이 없어요',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight:
                                        FontWeight.w600,
                                    color: Colors
                                        .grey.shade700,
                                  ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              '우측 상단 + 버튼으로\n첫 혈당 기록을 추가해보세요',
                              textAlign:
                                  TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors
                                        .grey.shade500,
                                    height: 1.5,
                                  ),
                            ),
                          ],
>>>>>>> 77c1b8faec2c030f2e4f6eb4c5b9b17531e0e916
                        ),
                      ),
                    )
                  : Padding(
                      padding:
                          const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: List.generate(
                          records.length,
                          (index) {
                            final record =
                                records[index];

                            bool showDateHeader =
                                false;

                            if (index == 0) {
                              showDateHeader = true;
                            } else {
                              final prevDate =
                                  _formatDate(
                                records[index - 1]
                                    .dateTime,
                              );

                              final currDate =
                                  _formatDate(
                                record.dateTime,
                              );

                              if (prevDate !=
                                  currDate) {
                                showDateHeader =
                                    true;
                              }
                            }

                            return Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                if (showDateHeader) ...[
                                  if (index > 0)
                                    const SizedBox(
                                      height: 32,
                                    ),

                                  DateHeader(
                                    date:
                                        _formatDate(
                                      record
                                          .dateTime,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 16,
                                  ),
                                ],

                                Padding(
                                  padding:
                                      const EdgeInsets.only(
                                    bottom: 20,
                                  ),
                                  child:
                                      BloodSugarRecordCard(
                                    record: record,
                                    onEdit:
                                        () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) =>
                                                  BloodSugarEditPage(
                                            record:
                                                record,
                                          ),
                                        ),
                                      );

                                      await loadRecords();
                                    },
                                    onDelete: () async {
                                      final bool? confirmDelete =
                                          await showDialog<bool>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                backgroundColor: Colors.white,

                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(24),
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
                                                        Navigator.pop(
                                                          context,
                                                          false,
                                                        ),

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
                                                        Navigator.pop(
                                                          context,
                                                          true,
                                                        ),

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
                                                content: Text(
                                                  '성공적으로 삭제되었습니다.',
                                                ),
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
                          },
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}