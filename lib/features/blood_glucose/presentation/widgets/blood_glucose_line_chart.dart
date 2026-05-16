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

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    final int index = value.toInt();

    if (index < 0 || index >= sortedRecords.length) {
      return const Text('');
    }

    final DateTime date = sortedRecords[index].dateTime;
    String text = '';

    if (selectedIndex == 0) {
      text = '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (selectedIndex == 1) {
      text = '${date.month}/${date.day}';
    } else {
      text = '${date.month}월';
    }

    return SideTitleWidget(
      meta: meta,
      space: 6,
      child: Text(
        text,
        style: const TextStyle(color: Colors.grey, fontSize: 11),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.only(right: 30, left: 0, top: 24, bottom: 10),
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
            horizontalInterval: 40,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[300],
                strokeWidth: 1,
                dashArray: [5, 5],
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
                reservedSize: 28,
                interval: 1,
                getTitlesWidget: _bottomTitleWidgets,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 50,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    meta: meta,
                    space: 4,
                    child: Text(
                      '${value.toInt()}',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
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
          maxY: 250,
        ),
      ),
    );
  }
}
