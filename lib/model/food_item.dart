class FoodItem {
  final String name;

  // 화면에 보여줄 양: "1그릇", "1잔", "1.0인분"
  final String amountLabel;

  // 계산/집계용 수치
  final double servingCount;

  final double calories;
  final double carbohydrate;
  final double protein;
  final double fat;
  final double sugar;

  FoodItem({
    required this.name,
    required this.amountLabel,
    required this.servingCount,
    required this.calories,
    required this.carbohydrate,
    required this.protein,
    required this.fat,
    required this.sugar,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amountLabel': amountLabel,
      'servingCount': servingCount,
      'calories': calories,
      'carbohydrate': carbohydrate,
      'protein': protein,
      'fat': fat,
      'sugar': sugar,
    };
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'] ?? '',
      amountLabel: json['amountLabel'] ?? '',
      servingCount: _toDouble(json['servingCount'], defaultValue: 1.0),
      calories: _toDouble(json['calories']),
      carbohydrate: _toDouble(json['carbohydrate']),
      protein: _toDouble(json['protein']),
      fat: _toDouble(json['fat']),
      sugar: _toDouble(json['sugar']),
    );
  }

  static double _toDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
}
