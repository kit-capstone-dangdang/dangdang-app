import 'package:dangdang/features/meal/domain/entities/food_item.dart';

Map<String, double> aggregateNutritionTotals(List<FoodItem> foods) {
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
