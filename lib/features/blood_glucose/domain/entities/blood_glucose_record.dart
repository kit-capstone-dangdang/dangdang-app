class BloodSugarRecord {
  final String id;
  final String uid;
  final DateTime dateTime;
  final int bloodSugar;
  final String mealState;
  final String memo;

  BloodSugarRecord({
    required this.id,
    required this.uid,
    required this.dateTime,
    required this.bloodSugar,
    required this.mealState,
    required this.memo,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'dateTime': dateTime.toIso8601String(),
      'bloodSugar': bloodSugar,
      'mealState': mealState,
      'memo': memo,
    };
  }

  factory BloodSugarRecord.fromJson(String id, Map<String, dynamic> json) {
    return BloodSugarRecord(
      id: id,
      uid: json['uid'] ?? '',
      dateTime: DateTime.parse(json['dateTime']),
      bloodSugar: json['bloodSugar'],
      mealState: json['mealState'],
      memo: json['memo'],
    );
  }
}
