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