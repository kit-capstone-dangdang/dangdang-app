import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dangdang/features/blood_glucose/domain/entities/blood_glucose_record.dart';
import 'package:dangdang/features/blood_glucose/data/repositories/firebase_blood_glucose_repository.dart';
import 'package:dangdang/features/blood_glucose/presentation/widgets/blood_glucose_line_chart.dart';
import 'package:dangdang/features/blood_glucose/presentation/widgets/blood_glucose_stat_card.dart';

class BloodSugarAnalysisScreen extends StatefulWidget {
  const BloodSugarAnalysisScreen({super.key});

  @override
  State<BloodSugarAnalysisScreen> createState() =>
      _BloodSugarAnalysisScreenState();
}

class _BloodSugarAnalysisScreenState extends State<BloodSugarAnalysisScreen> {
  int _selectedIndex = 1;

  final FirebaseBloodSugarRepository _repository =
      FirebaseBloodSugarRepository();

  List<BloodGlucoseRecord> _realRecords = [];
  bool _isLoading = true;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final records = await _repository.getRecords();

      if (mounted) {
        setState(() {
          _realRecords = records;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  DateTime get _targetDate {
    if (_realRecords.isEmpty) return DateTime.now();
    return _realRecords
        .map((e) => e.dateTime)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  List<BloodGlucoseRecord> get _processedRecords {
    final target = _targetDate;

    if (_selectedIndex == 0) {
      // 일간
      var daily = _realRecords
          .where(
            (r) =>
                r.dateTime.year == target.year &&
                r.dateTime.month == target.month &&
                r.dateTime.day == target.day,
          )
          .toList();
      daily.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return daily;
    } else if (_selectedIndex == 1) {
      // 주간
      var weekAgo = target.subtract(const Duration(days: 7));
      var weeklyRaw = _realRecords
          .where((r) => r.dateTime.isAfter(weekAgo))
          .toList();

      Map<int, List<int>> dailyMap = {};
      for (var r in weeklyRaw) {
        dailyMap.putIfAbsent(r.dateTime.day, () => []).add(r.bloodSugar);
      }

      List<BloodGlucoseRecord> averaged = [];
      dailyMap.forEach((day, values) {
        int avg = (values.reduce((a, b) => a + b) / values.length).round();
        averaged.add(
          BloodGlucoseRecord(
            id: '',
            uid: _uid,
            dateTime: DateTime(target.year, target.month, day),
            bloodSugar: avg,
            mealState: '평균',
            memo: '',
          ),
        );
      });
      averaged.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return averaged;
    } else {
      // 월간
      var monthlyRaw = _realRecords
          .where((r) => r.dateTime.year == target.year) //올해데이터만
          .toList();

      Map<int, List<int>> monthMap = {};
      for (var r in monthlyRaw) {
        monthMap.putIfAbsent(r.dateTime.month, () => []).add(r.bloodSugar);
      }

      List<BloodGlucoseRecord> averaged = [];
      monthMap.forEach((month, values) {
        int avg = (values.reduce((a, b) => a + b) / values.length).round();
        averaged.add(
          BloodGlucoseRecord(
            id: '',
            uid: _uid,
            dateTime: DateTime(target.year, month, 1),
            bloodSugar: avg,
            mealState: '평균',
            memo: '',
          ),
        );
      });
      averaged.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return averaged;
    }
  }

  List<FlSpot> get _chartSpots {
    final records = _processedRecords;
    List<FlSpot> spots = [];
    for (int i = 0; i < records.length; i++) {
      spots.add(FlSpot(i.toDouble(), records[i].bloodSugar.toDouble()));
    }
    return spots;
  }

  List<BloodGlucoseRecord> get _currentPeriodRawRecords {
    final target = _targetDate;
    if (_selectedIndex == 0) {
      return _realRecords
          .where(
            (r) =>
                r.dateTime.year == target.year &&
                r.dateTime.month == target.month &&
                r.dateTime.day == target.day,
          )
          .toList();
    } else if (_selectedIndex == 1) {
      var weekAgo = target.subtract(const Duration(days: 7));
      return _realRecords.where((r) => r.dateTime.isAfter(weekAgo)).toList();
    } else {
      return _realRecords
          .where(
            (r) =>
                r.dateTime.year == target.year &&
                r.dateTime.month == target.month,
          )
          .toList();
    }
  }

  List<BloodGlucoseRecord> get _previousPeriodRawRecords {
    final target = _targetDate;
    if (_selectedIndex == 0) {
      final yesterday = target.subtract(const Duration(days: 1));
      return _realRecords
          .where(
            (r) =>
                r.dateTime.year == yesterday.year &&
                r.dateTime.month == yesterday.month &&
                r.dateTime.day == yesterday.day,
          )
          .toList();
    } else if (_selectedIndex == 1) {
      var weekAgo = target.subtract(const Duration(days: 7));
      var twoWeeksAgo = target.subtract(const Duration(days: 14));
      return _realRecords
          .where(
            (r) =>
                r.dateTime.isAfter(twoWeeksAgo) &&
                (r.dateTime.isBefore(weekAgo) ||
                    r.dateTime.isAtSameMomentAs(weekAgo)),
          )
          .toList();
    } else {
      final previousMonthDate = DateTime(target.year, target.month - 1, 1);
      return _realRecords
          .where(
            (r) =>
                r.dateTime.year == previousMonthDate.year &&
                r.dateTime.month == previousMonthDate.month,
          )
          .toList();
    }
  }

  int get _averageBloodSugar {
    final records = _currentPeriodRawRecords;
    if (records.isEmpty) return 0;
    int sum = records.fold(0, (prev, element) => prev + element.bloodSugar);
    return (sum / records.length).round();
  }

  int get _previousAverageBloodSugar {
    final records = _previousPeriodRawRecords;
    if (records.isEmpty) return 0;
    int sum = records.fold(0, (prev, element) => prev + element.bloodSugar);
    return (sum / records.length).round();
  }

  String get _averageComparisonText {
    final currentAvg = _averageBloodSugar;
    final prevAvg = _previousAverageBloodSugar;

    String prefix = '';
    if (_selectedIndex == 0)
      prefix = '어제';
    else if (_selectedIndex == 1)
      prefix = '지난주';
    else
      prefix = '지난달';

    if (prevAvg == 0) return '$prefix 데이터 없음';

    int diffPercentage = (((currentAvg - prevAvg) / prevAvg) * 100).round();
    if (diffPercentage > 0) {
      return '$prefix 대비 +$diffPercentage%';
    } else if (diffPercentage < 0) {
      return '$prefix 대비 $diffPercentage%';
    } else {
      return '$prefix과 동일';
    }
  }

  Color get _averageComparisonColor {
    final currentAvg = _averageBloodSugar;
    final prevAvg = _previousAverageBloodSugar;
    if (prevAvg == 0 || currentAvg == prevAvg) return Colors.grey;
    return currentAvg > prevAvg ? Colors.redAccent : Colors.green;
  }

  BloodGlucoseRecord? get _maxRecord {
    final records = _currentPeriodRawRecords;
    if (records.isEmpty) return null;
    return records.reduce(
      (curr, next) => curr.bloodSugar > next.bloodSugar ? curr : next,
    );
  }

  int get _maxBloodSugar => _maxRecord?.bloodSugar ?? 0;

  String get _maxRecordTimeText {
    final record = _maxRecord;
    if (record == null) return '데이터 없음';
    final dt = record.dateTime;
    return '${dt.month}월 ${dt.day}일 ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTabButtons(),
                  const SizedBox(height: 24),

                  BloodGlucoseLineChart(
                    chartSpots: _chartSpots,
                    sortedRecords: _processedRecords,
                    selectedIndex: _selectedIndex,
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: BloodGlucoseStatCard(
                          title: '평균 혈당',
                          value: _averageBloodSugar.toString(),
                          subText: _averageComparisonText,
                          subTextColor: _averageComparisonColor,
                          valueColor: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: BloodGlucoseStatCard(
                          title: '최고 혈당',
                          value: _maxBloodSugar.toString(),
                          subText: _maxRecordTimeText,
                          subTextColor: Colors.grey,
                          valueColor: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

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
