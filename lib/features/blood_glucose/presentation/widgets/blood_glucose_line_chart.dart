import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/blood_glucose_record.dart';

class BloodGlucoseLineChart extends StatelessWidget {
  final List<FlSpot> chartSpots;
  final List<BloodGlucoseRecord> sortedRecords;
  final int selectedIndex;

  const BloodGlucoseLineChart({
    super.key,
    required this.chartSpots,
    required this.sortedRecords,
    required this.selectedIndex,
  });

  // 💡 탭(일/주/월)에 따라 X축 라벨 글씨를 다르게 그려주는 함수
  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    final int index = value.toInt();

    // 인덱스 범위 초과 방지
    if (index < 0 || index >= sortedRecords.length) {
      return const Text('');
    }

    final DateTime date = sortedRecords[index].dateTime;
    String text = '';

    if (selectedIndex == 0) {
      // 일간: 시간:분 표시 (예: 14:30)
      text = '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (selectedIndex == 1) {
      // 주간: 월/일 표시 (예: 3/25)
      text = '${date.month}/${date.day}';
    } else {
      // 💡 [수정] 월간: N월 표시 (예: 1월, 2월, 3월)
      text = '${date.month}월';
    }

    return SideTitleWidget(
      meta: meta,
      space: 8, // 차트와 라벨 사이의 간격
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
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[300],
                strokeWidth: 1,
                dashArray: [5, 5], // 💡 가로선을 점선으로 만들어 훨씬 깔끔하게 표시
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
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
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blueAccent.withOpacity(0.1),
              ),
            ),
          ],
          minY: 60,
          maxY: 200, // 혈당 수치에 따라 자동 조절하려면 로직 추가 가능
        ),
      ),
    );
  }
}
