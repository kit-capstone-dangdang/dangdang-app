import 'package:dangdang/features/blood_glucose/domain/entities/blood_sugar_record.dart';

final dummyBloodSugarRecords = [
  // 💡 3월 26일 (오늘)
  BloodSugarRecord(
    id: '1',
    dateTime: DateTime(2026, 3, 26, 7, 30),
    bloodSugar: 105,
    mealState: '공복',
    memo: '꿀잠 자고 일어남',
  ),
  BloodSugarRecord(
    dateTime: DateTime(2026, 3, 26, 13, 10),
    bloodSugar: 138,
    mealState: '식후',
    memo: '회사 구내식당 (돈까스)',
  ),

  // 💡 3월 25일 (어제)
  BloodSugarRecord(
    id: '2',
    dateTime: DateTime(2026, 3, 25, 8, 0),
    bloodSugar: 110,
    mealState: '공복',
    memo: '조금 피곤함',
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
    memo: '가벼운 산책 후',
  ),
  BloodSugarRecord(
    dateTime: DateTime(2026, 3, 25, 23, 30),
    bloodSugar: 102,
    mealState: '취침전',
    memo: '자기 전 측정',
  ),

  // 💡 3월 24일
  BloodSugarRecord(
    dateTime: DateTime(2026, 3, 24, 7, 45),
    bloodSugar: 98,
    mealState: '공복',
    memo: '컨디션 좋음',
  ),
  BloodSugarRecord(
    dateTime: DateTime(2026, 3, 24, 14, 0),
    bloodSugar: 155,
    mealState: '식후',
    memo: '간식으로 마카롱 먹음 ㅠㅠ',
  ),
  BloodSugarRecord(
    dateTime: DateTime(2026, 3, 24, 19, 0),
    bloodSugar: 115,
    mealState: '식전',
    memo: '저녁 먹기 전',
  ),

  // 💡 3월 23일
  BloodSugarRecord(
    dateTime: DateTime(2026, 3, 23, 8, 10),
    bloodSugar: 108,
    mealState: '공복',
    memo: '',
  ),
  BloodSugarRecord(
    dateTime: DateTime(2026, 3, 23, 12, 30),
    bloodSugar: 105,
    mealState: '식전',
    memo: '',
  ),
  BloodSugarRecord(
    dateTime: DateTime(2026, 3, 23, 14, 30),
    bloodSugar: 135,
    mealState: '식후',
    memo: '건강한 한식',
  ),
  BloodSugarRecord(
    dateTime: DateTime(2026, 3, 23, 20, 0),
    bloodSugar: 142,
    mealState: '식후',
    memo: '저녁 고기 구워 먹음',
  ),

  // 💡 3월 22일 (치팅데이 느낌)
  BloodSugarRecord(
    dateTime: DateTime(2026, 3, 22, 9, 0),
    bloodSugar: 112,
    mealState: '공복',
    memo: '주말 늦잠',
  ),
  BloodSugarRecord(
    dateTime: DateTime(2026, 3, 22, 15, 0),
    bloodSugar: 165,
    mealState: '식후',
    memo: '뷔페 다녀옴, 혈당 스파이크 온 듯',
  ),
  BloodSugarRecord(
    dateTime: DateTime(2026, 3, 22, 22, 0),
    bloodSugar: 130,
    mealState: '취침전',
    memo: '아직 배부름',
  ),

  // 💡 3월 21일
  BloodSugarRecord(
    dateTime: DateTime(2026, 3, 21, 7, 50),
    bloodSugar: 95,
    mealState: '공복',
    memo: '정상',
  ),
  BloodSugarRecord(
    dateTime: DateTime(2026, 3, 21, 13, 20),
    bloodSugar: 132,
    mealState: '식후',
    memo: '비빔밥',
  ),

  // 💡 3월 20일
  BloodSugarRecord(
    dateTime: DateTime(2026, 3, 20, 8, 0),
    bloodSugar: 100,
    mealState: '공복',
    memo: '혈당 기록 시작!',
  ),
];
