import 'package:dangdang/features/blood_glucose/domain/entities/blood_sugar_record.dart';

final dummyBloodSugarRecords = [
  BloodSugarRecord(
    id: '1',
    dateTime: DateTime(2026, 3, 26, 7, 30),
    bloodSugar: 105,
    mealState: '공복',
    memo: '꿀잠',
  ),

  BloodSugarRecord(
    id: '2',
    dateTime: DateTime(2026, 3, 25, 8, 0),
    bloodSugar: 110,
    mealState: '공복',
    memo: '상태 좋음',
  ),

  BloodSugarRecord(
    id: '3',
    dateTime: DateTime(2026, 3, 25, 13, 0),
    bloodSugar: 145,
    mealState: '식후',
    memo: '점심 김치찌개',
  ),

  BloodSugarRecord(
    id: '4',
    dateTime: DateTime(2026, 3, 25, 17, 0),
    bloodSugar: 120,
    mealState: '식전',
    memo: '운동후',
  ),
];