import '../model/meal_record.dart';

abstract class MealRepository {
  Future<void> createMeal(MealRecord meal);
  Future<List<MealRecord>> getMeals();
  Future<void> updateMeal(MealRecord meal);
  Future<void> deleteMeal(String id);
}
