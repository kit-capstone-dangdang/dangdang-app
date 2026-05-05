import 'food_item.dart';

class MealRecord {
  final String id;
  final DateTime dateTime;
  final String mealType;
  final List<FoodItem> foods;

  MealRecord({
    required this.id,
    required this.dateTime,
    required this.mealType,
    required this.foods,
  });

  Map<String, dynamic> toJson() {
    return {
      'dateTime': dateTime.toIso8601String(),
      'mealType': mealType,
      'foods': foods.map((e) => e.toJson()).toList(),
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
    );
  }
}