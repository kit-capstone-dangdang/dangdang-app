// 혈당 기록 한 건을 담는 데이터 모델 (엔티티)
class BloodSugarRecord {
  final DateTime dateTime;

  final int bloodSugar;

  final String mealState;

  final String memo;

  BloodSugarRecord({
    required this.dateTime,
    required this.bloodSugar,
    required this.mealState,
    required this.memo,
  });
}
