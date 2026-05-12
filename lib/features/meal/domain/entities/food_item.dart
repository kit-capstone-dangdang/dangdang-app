import 'package:dangdang/core/utils/parsers/value_parser.dart';

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
      servingCount: parseDouble(json['servingCount'], defaultValue: 1.0),
      calories: parseDouble(json['calories']),
      carbohydrate: parseDouble(json['carbohydrate']),
      protein: parseDouble(json['protein']),
      fat: parseDouble(json['fat']),
      sugar: parseDouble(json['sugar']),
    );
  }

  FoodItem scaled(double quantity) {
    return FoodItem(
      name: name,
      amountLabel: amountLabel,
      servingCount: quantity,
      calories: calories * quantity,
      carbohydrate: carbohydrate * quantity,
      protein: protein * quantity,
      fat: fat * quantity,
      sugar: sugar * quantity,
    );
  }
}
