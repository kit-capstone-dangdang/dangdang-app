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
}