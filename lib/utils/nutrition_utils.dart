import '../models/food_item.dart';

double parseDouble(dynamic value, {double defaultValue = 0.0}) {
  if (value is int) return value.toDouble();
  if (value is double) return value;
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}

double calculateCalories({
  required double carbohydrate,
  required double protein,
  required double fat,
}) {
  return (carbohydrate * 4) + (protein * 4) + (fat * 9);
}

Map<String, double> calculateTotalNutrition(List<FoodItem> foods) {
  double calories = 0;
  double carbohydrate = 0;
  double protein = 0;
  double fat = 0;
  double sugar = 0;

  for (final food in foods) {
    calories += food.calories;
    carbohydrate += food.carbohydrate;
    protein += food.protein;
    fat += food.fat;
    sugar += food.sugar;
  }

  return {
    'calories': calories,
    'carbohydrate': carbohydrate,
    'protein': protein,
    'fat': fat,
    'sugar': sugar,
  };
}

extension FoodItemNutritionExtension on FoodItem {
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
