import 'food_item.dart';

class MealRecord {
  final String id;
  final DateTime dateTime;
  final String mealType;
  final List<FoodItem> foods;
  final String aiComment;

  MealRecord({
    required this.id,
    required this.dateTime,
    required this.mealType,
    required this.foods,
    required this.aiComment,
  });

  // firebase 저장 형태
  Map<String, dynamic> toJson() {
    return {
      'dateTime': dateTime.toIso8601String(),
      'mealType': mealType,
      'foods': foods.map((e) => e.toJson()).toList(),
      'aiComment': aiComment,
    };
  }

  factory MealRecord.fromJson(String id, Map<String, dynamic> json) {
    return MealRecord(
      id: id,
      dateTime: DateTime.parse(json['dateTime']),
      mealType: json['mealType'],
      foods: (json['foods'] as List)
          .map((e) => FoodItem.fromJson(e))
          .toList(),
      aiComment: json['aiComment'] ?? '',
    );
  }
}

// 객체 (Dart class)
//    ↓ toJson()
// Map (Firebase 저장 형태)
//    ↓ fromJson()
// 다시 객체