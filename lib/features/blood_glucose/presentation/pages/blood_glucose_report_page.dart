import 'package:flutter/material.dart';
import 'package:dangdang/features/blood_glucose/data/datasources/blood_sugar_dummy_data.dart';
import 'package:dangdang/features/blood_glucose/domain/entities/blood_sugar_record.dart';
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
  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}';
  }

  void _refreshList() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // 최신순 정렬 후 4개 데이터만 추출
    var sortedRecords = List<BloodSugarRecord>.from(dummyBloodSugarRecords);
    sortedRecords.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    var displayRecords = sortedRecords.take(4).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '혈당 기록',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.show_chart_outlined,
              size: 28,
              color: Colors.black54,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BloodSugarAnalysisScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_box, size: 28, color: Colors.blue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BloodSugarAddPage(),
                ),
              ).then((_) => _refreshList());
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Container(
        color: const Color(0xFFF9FAFB),
        padding: const EdgeInsets.all(16),
        child: displayRecords.isEmpty
            ? const Center(child: Text("데이터가 없습니다."))
            : ListView.builder(
                itemCount: displayRecords.length,
                itemBuilder: (context, index) {
                  final record = displayRecords[index];
                  bool showDateHeader = false;

                  if (index == 0) {
                    showDateHeader = true;
                  } else {
                    final prevDate = _formatDate(
                      displayRecords[index - 1].dateTime,
                    );
                    final currDate = _formatDate(record.dateTime);
                    if (prevDate != currDate) showDateHeader = true;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showDateHeader) ...[
                        if (index > 0) const SizedBox(height: 24),
                        DateHeader(date: _formatDate(record.dateTime)),
                        const SizedBox(height: 16),
                      ],
                      BloodSugarRecordCard(
                        record: record,
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  BloodSugarEditPage(record: record),
                            ),
                          ).then((_) => _refreshList());
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
