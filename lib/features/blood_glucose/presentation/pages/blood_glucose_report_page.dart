import 'package:flutter/material.dart';
import 'package:dangdang/core/widgets/common/custom_icon.dart';
import 'package:dangdang/features/blood_glucose/data/datasources/blood_sugar_dummy_data.dart';
import 'package:dangdang/features/blood_glucose/presentation/pages/blood_glucose_analysis_page.dart';
import 'package:dangdang/features/blood_glucose/presentation/pages/blood_sugar_add_page.dart';
import 'package:dangdang/features/blood_glucose/presentation/pages/blood_sugar_edit_page.dart';
import 'package:dangdang/features/blood_glucose/presentation/widgets/blood_glucose_stat_card.dart';

class BloodSugarRecordPage extends StatelessWidget {
  const BloodSugarRecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 타이틀 설정
        title: const Text(
          '혈당 기록',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: false, // 왼쪽 정렬
        actions: [
          // ⭐️ 사용자가 누를 화살표(그래프) 모양 아이콘 버튼입니다.
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
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add_box, size: 28, color: Colors.blue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BloodSugarAddPage(),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Container(
        color: const Color(0xFFF9FAFB), // 옅은 배경색
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Text(
            '최근 혈당 및 리포트 내역이 여기에 표시됩니다.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
