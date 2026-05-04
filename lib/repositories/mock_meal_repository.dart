import '../model/meal_record.dart';
import 'meal_repository.dart';

class MockMealRepository implements MealRepository {
  final List<MealRecord> _data = []; // 임시 데이터 저장소

  @override
  Future<void> createMeal(MealRecord meal) async {
    _data.add(meal); // 새로운 식사 기록 추가
  }

  @override
  Future<List<MealRecord>> getMeals() async {
    return _data; // 모든 식사 기록 반환
  }

  @override
  Future<void> updateMeal(MealRecord meal) async { // 식사 기록 업데이트
    final index = _data.indexWhere((e) => e.id == meal.id);
    if (index != -1) {
      _data[index] = meal;
    }
  }

  @override
  Future<void> deleteMeal(String id) async { // 식사 기록 삭제
    _data.removeWhere((e) => e.id == id);
  }
}