// 혈당 곡선 그래프

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/blood_sugar_record.dart';

class BloodGlucoseLineChart extends StatelessWidget {
  final List<FlSpot> chartSpots;
  final List<BloodSugarRecord> sortedRecords;
  final int selectedIndex;

  const BloodGlucoseLineChart({
    super.key,
    required this.chartSpots,
    required this.sortedRecords,
    required this.selectedIndex,
  });

  // 탭(일/주/월)에 따라 X축 라벨 글씨를 다르게 그려주는 함수
  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    final int index = value.toInt();

    if (index < 0 || index >= sortedRecords.length) {
      return const Text('');
    }

    final DateTime date = sortedRecords[index].dateTime;
    String text = '';

    if (selectedIndex == 0) {
      // 일간: 시간 표시 (예: 14시)
      text = '${date.hour}시';
    } else if (selectedIndex == 1) {
      // 💡 주간(대시보드): 2주차, 3주차가 아니라 날짜로 표시하도록 변경! (예: 5/13)
      text = '${date.month}/${date.day}';
    } else {
      // 월간: 월 표시 (예: 5월)
      text = '${date.month}월';
    }

    return SideTitleWidget(
      meta: meta,
      child: Text(
        text,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.only(right: 20, left: 0, top: 24, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 30,
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: _bottomTitleWidgets,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 30,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: chartSpots,
              isCurved: true,
              color: Colors.blueAccent,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blueAccent.withOpacity(0.1),
              ),
            ),
          ],
          minY: 60,
          maxY: 200,
        ),
      ),
    );
  }
}
