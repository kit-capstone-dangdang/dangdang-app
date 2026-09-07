import 'package:dangdang/features/blood_glucose/domain/entities/blood_glucose_record.dart';
import 'package:dangdang/features/blood_glucose/domain/services/blood_glucose_risk_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

BloodGlucoseRecord record(int bg, [String state = '공복']) => BloodGlucoseRecord(
  id: '',
  uid: '',
  dateTime: DateTime(2026, 9, 7),
  bloodSugar: bg,
  mealState: state,
  memo: '',
);

void main() {
  test('low risk permits five stars', () {
    final result = calculateBloodGlucoseRisk([record(100)]);
    expect(result.lbgi, closeTo(0.4820511254, 1e-8));
    expect(result.hbgi, 0);
    expect(result.riskLevel, BloodGlucoseRiskLevel.low);
    expect(result.targetRate, 1);
    expect(result.finalRating, 5);
  });

  test('moderate LBGI caps otherwise perfect target rate at 3.5', () {
    final result = calculateBloodGlucoseRisk([record(80)]);
    expect(result.lbgi, closeTo(4.0153536182, 1e-8));
    expect(result.riskLevel, BloodGlucoseRiskLevel.moderate);
    expect(result.finalRating, 3.5);
  });

  test('moderate HBGI caps otherwise perfect target rate at 3.5', () {
    final result = calculateBloodGlucoseRisk([record(170, '식후')]);
    expect(result.hbgi, closeTo(5.9574041499, 1e-8));
    expect(result.riskLevel, BloodGlucoseRiskLevel.moderate);
    expect(result.finalRating, 3.5);
  });

  test('high HBGI wins over low LBGI and caps rating at two', () {
    final result = calculateBloodGlucoseRisk([record(100), record(250, '취침전')]);
    expect(result.hbgi, closeTo(11.2180998333, 1e-8));
    expect(result.riskLevel, BloodGlucoseRiskLevel.high);
    expect(result.targetRate, 1);
    expect(result.finalRating, 2);
  });

  test(
    'severe hypoglycemia limits rating despite post-meal target success',
    () {
      final result = calculateBloodGlucoseRisk([
        record(100, '식후'),
        record(40, '식후'),
      ]);
      expect(result.lbgi, closeTo(18.4497989458, 1e-8));
      expect(result.targetRate, 1);
      expect(result.riskLevel, BloodGlucoseRiskLevel.high);
      expect(result.finalRating, 2);
    },
  );

  test('both indices divide by all valid records, including opposite side', () {
    final result = calculateBloodGlucoseRisk([record(80), record(170)]);
    expect(result.lbgi, closeTo(4.0153536182 / 2, 1e-8));
    expect(result.hbgi, closeTo(5.9574041499 / 2, 1e-8));
    expect(result.riskLevel, BloodGlucoseRiskLevel.low);
  });

  test(
    'zero and negative BG are excluded from risk and target denominators',
    () {
      final result = calculateBloodGlucoseRisk([
        record(0, '식후'),
        record(-40),
        record(100),
      ]);
      expect(result.lbgi, closeTo(0.4820511254, 1e-8));
      expect(result.hbgi, 0);
      expect(result.targetRate, 1);
      expect(result.finalRating, 5);
    },
  );

  for (final values in <List<int>>[
    [],
    [0, -1],
  ]) {
    test('no valid values $values means unavailable, not half a star', () {
      final result = calculateBloodGlucoseRisk(
        values.map((bg) => record(bg)).toList(),
      );
      expect(result.lbgi, isNull);
      expect(result.hbgi, isNull);
      expect(result.riskLevel, isNull);
      expect(result.targetRate, isNull);
      expect(result.finalRating, isNull);
    });
  }

  test('bedtime and unknown states retain risk but cannot produce rating', () {
    final result = calculateBloodGlucoseRisk([
      record(40, '취침전'),
      record(100, '기타'),
    ]);
    expect(result.riskLevel, BloodGlucoseRiskLevel.high);
    expect(result.targetRate, isNull);
    expect(result.finalRating, isNull);
  });

  test(
    'fasting and pre-meal boundaries are inclusive; post-meal is strict',
    () {
      final result = calculateBloodGlucoseRisk([
        for (final state in ['공복', '식전'])
          for (final bg in [79, 80, 130, 131]) record(bg, state),
        record(179, '식후'),
        record(180, '식후'),
      ]);
      expect(result.targetRate, 0.5);
      expect(result.finalRating, 2.5);
    },
  );

  for (final example in [(2, 3, 3.5), (1, 3, 1.5), (1, 4, 1.5), (0, 3, 0.5)]) {
    test('rounds ${example.$1}/${example.$2} to ${example.$3} stars', () {
      final result = calculateBloodGlucoseRisk([
        for (var i = 0; i < example.$2; i++) record(i < example.$1 ? 100 : 131),
      ]);
      expect(result.riskLevel, BloodGlucoseRiskLevel.low);
      expect(result.finalRating, example.$3);
    });
  }

  test('positive minimum integer BG produces finite risk', () {
    final result = calculateBloodGlucoseRisk([record(1)]);
    expect(result.lbgi!.isFinite, isTrue);
    expect(result.riskLevel, BloodGlucoseRiskLevel.high);
    expect(result.finalRating, 0.5);
  });
}
