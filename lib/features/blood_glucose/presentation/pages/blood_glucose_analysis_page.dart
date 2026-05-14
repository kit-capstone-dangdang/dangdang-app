// 혈당 분석(그래프) 화면

import 'package:dangdang/features/blood_glucose/data/datasources/blood_sugar_dummy_data.dart';
import 'package:dangdang/features/blood_glucose/domain/entities/blood_sugar_record.dart';
import 'package:dangdang/features/blood_glucose/presentation/widgets/ai_report_card.dart';
import 'package:dangdang/features/blood_glucose/presentation/widgets/blood_glucose_line_chart.dart';
import 'package:dangdang/features/blood_glucose/presentation/widgets/blood_glucose_stat_card.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BloodSugarAnalysisScreen extends StatefulWidget {
  const BloodSugarAnalysisScreen({super.key});

  @override
  State<BloodSugarAnalysisScreen> createState() =>
      _BloodSugarAnalysisScreenState();
}

class _BloodSugarAnalysisScreenState extends State<BloodSugarAnalysisScreen> {
  int _selectedIndex = 1;

  List<BloodSugarRecord> get _sortedRecords {
    var sorted = List<BloodSugarRecord>.from(dummyBloodSugarRecords);
    sorted.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return sorted;
  }

  List<FlSpot> get _chartSpots {
    final records = _sortedRecords;
    List<FlSpot> spots = [];
    for (int i = 0; i < records.length; i++) {
      spots.add(FlSpot(i.toDouble(), records[i].bloodSugar.toDouble()));
    }
    return spots;
  }

  int get _averageBloodSugar {
    if (dummyBloodSugarRecords.isEmpty) return 0;
    int sum = 0;
    for (var record in dummyBloodSugarRecords) {
      sum += record.bloodSugar;
    }
    return (sum / dummyBloodSugarRecords.length).round();
  }

  int get _maxBloodSugar {
    if (dummyBloodSugarRecords.isEmpty) return 0;
    int max = dummyBloodSugarRecords[0].bloodSugar;
    for (var record in dummyBloodSugarRecords) {
      if (record.bloodSugar > max) {
        max = record.bloodSugar;
      }
    }
    return max;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '혈당 분석',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTabButtons(),
            const SizedBox(height: 24),

            // 💡 분리한 그래프 위젯 사용
            BloodGlucoseLineChart(
              chartSpots: _chartSpots,
              sortedRecords: _sortedRecords,
              selectedIndex: _selectedIndex,
            ),

            const SizedBox(height: 24),

            // 💡 분리한 통계 카드 위젯 사용
            Row(
              children: [
                Expanded(
                  child: BloodGlucoseStatCard(
                    title: '평균 혈당',
                    value: _averageBloodSugar.toString(),
                    subText: '지난주 대비 -5%',
                    subTextColor: Colors.green,
                    valueColor: Colors.blueAccent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: BloodGlucoseStatCard(
                    title: '최고 혈당',
                    value: _maxBloodSugar.toString(),
                    subText: '최근 기록 기준',
                    subTextColor: Colors.grey,
                    valueColor: Colors.redAccent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 💡 분리한 AI 리포트 위젯 사용
            const AIReportCard(
              reportText:
                  '최근 식후 혈당이 조금 높게 측정되고 있습니다. 점심 식사 후 15분 정도 가벼운 산책을 추천드려요!',
            ),
          ],
        ),
      ),
    );
  }

  // 탭 버튼은 이 화면에서만 쓰이고 상태 변화(setState)가 필요하므로 여기에 남겨둡니다.
  Widget _buildTabButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: ['일간', '주간', '월간'].asMap().entries.map((entry) {
          int index = entry.key;
          String label = entry.value;
          bool isSelected = _selectedIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.blueAccent : Colors.grey,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
