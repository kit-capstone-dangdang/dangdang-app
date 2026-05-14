import 'package:dangdang/core/widgets/common/custom_icon.dart';
import 'package:dangdang/features/blood_glucose/data/datasources/blood_sugar_dummy_data.dart';
import 'package:dangdang/features/blood_glucose/presentation/pages/blood_glucose_analysis_page.dart';
import 'package:dangdang/features/blood_glucose/presentation/pages/blood_sugar_add_page.dart';
import 'package:dangdang/features/blood_glucose/presentation/pages/blood_sugar_edit_page.dart';
import 'package:dangdang/features/blood_glucose/presentation/widgets/blood_sugar_record_card.dart';
import 'package:dangdang/features/meal/presentation/widgets/date_header.dart';
import 'package:flutter/material.dart';

class BloodSugarRecordPage extends StatelessWidget {
  const BloodSugarRecordPage({super.key});

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final records = dummyBloodSugarRecords;

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
                              builder: (context) =>
                                  const BloodSugarAnalysisScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.add_box,
                          size: 28,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BloodSugarAddPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SliverToBoxAdapter(
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      BloodSugarEditPage(record: record),
                                ),
                              );
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
