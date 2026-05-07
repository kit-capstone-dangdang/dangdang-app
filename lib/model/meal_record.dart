import 'food_item.dart';

class MealRecord {
  final String id;
  final DateTime dateTime;
  final String mealType;
  final List<FoodItem> foods;

  // Gemini 분석 코멘트
  final String aiComment;

  // 전체 영양 합계
  final Map<String, double> totalNutrition;

  MealRecord({
    required this.id,
    required this.dateTime,
    required this.mealType,
    required this.foods,
    required this.aiComment,
    required this.totalNutrition,
  });

  Map<String, dynamic> toJson() {
    return {
      'dateTime': dateTime.toIso8601String(),
      'mealType': mealType,
      'foods': foods.map((e) => e.toJson()).toList(),
      'aiComment': aiComment,
      'totalNutrition': totalNutrition,
    };
  }

  factory MealRecord.fromJson(String id, Map<String, dynamic> json) {
    return MealRecord(
      id: id,
      dateTime: DateTime.parse(json['dateTime']),
      mealType: json['mealType'] ?? '',
      foods: (json['foods'] as List<dynamic>? ?? [])
          .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      aiComment: json['aiComment'] ?? '',
      totalNutrition: _parseTotalNutrition(json['totalNutrition']),
    );
  }

  static Map<String, double> _parseTotalNutrition(dynamic value) {
    final map = value as Map<String, dynamic>? ?? {};

    return {
      'calories': _toDouble(map['calories']),
      'carbohydrate': _toDouble(map['carbohydrate']),
      'protein': _toDouble(map['protein']),
      'fat': _toDouble(map['fat']),
      'sugar': _toDouble(map['sugar']),
    };
  }

  static double _toDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
