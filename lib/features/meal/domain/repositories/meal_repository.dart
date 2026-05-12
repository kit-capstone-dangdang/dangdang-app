import 'package:dangdang/features/meal/domain/entities/meal_record.dart';

abstract class MealRepository {
  Future<void> createMeal(MealRecord meal);
  Future<List<MealRecord>> getMeals();
  Stream<List<MealRecord>> watchMeals();
  Stream<MealRecord?> watchMeal(String id);
  Future<void> updateMeal(MealRecord meal, {String? oldImageUrl});
  Future<void> deleteMeal(String id, {String? imageUrl});
}
