import 'package:dangdang/core/utils/parsers/value_parser.dart';
import 'package:dangdang/features/meal/domain/entities/food_item.dart';
import 'package:dangdang/features/meal/domain/services/nutrition_aggregator.dart';

class MealRecord {
  final String id;
  final String uid;
  final DateTime dateTime;
  final String mealType;
  final List<FoodItem> foods;

  // Firebase Storage 이미지 URL
  final String imageUrl;

  // Gemini 분석 코멘트
  final String aiComment;

  // 전체 영양 합계
  final Map<String, double> totalNutrition;

  MealRecord({
    required this.id,
    required this.uid,
    required this.dateTime,
    required this.mealType,
    required this.foods,
    required this.imageUrl,
    required this.aiComment,
    required this.totalNutrition,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'dateTime': dateTime.toIso8601String(),
      'mealType': mealType,
      'foods': foods.map((e) => e.toJson()).toList(),
      'imageUrl': imageUrl,
      'aiComment': aiComment,
      'totalNutrition': totalNutrition,
    };
  }

  factory MealRecord.fromJson(String id, Map<String, dynamic> json) {
    return MealRecord(
      id: id,
      uid: json['uid'] ?? '',
      dateTime: DateTime.parse(json['dateTime']),
      mealType: json['mealType'] ?? '',
      foods: (json['foods'] as List<dynamic>? ?? [])
          .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      imageUrl: json['imageUrl'] ?? '',
      aiComment: json['aiComment'] ?? '',
      totalNutrition: _parseTotalNutrition(json['totalNutrition']),
    );
  }

  static Map<String, double> totalNutritionFromFoods(List<FoodItem> foods) {
    return aggregateNutritionTotals(foods);
  }

  static Map<String, double> _parseTotalNutrition(dynamic value) {
    final map = value as Map<String, dynamic>? ?? {};

    return {
      'calories': parseDouble(map['calories']),
      'carbohydrate': parseDouble(map['carbohydrate']),
      'protein': parseDouble(map['protein']),
      'fat': parseDouble(map['fat']),
      'sugar': parseDouble(map['sugar']),
    };
  }
}
