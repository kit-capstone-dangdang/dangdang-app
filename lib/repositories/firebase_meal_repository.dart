import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/meal_record.dart';
import 'meal_repository.dart';

class FirebaseMealRepository implements MealRepository {
  final _collection = FirebaseFirestore.instance.collection('mealRecords');

  /// CREATE
  @override
  Future<void> createMeal(MealRecord meal) async {
    await _collection.add(meal.toJson());
  }

  /// READ
  @override
  Future<List<MealRecord>> getMeals() async {
    final snapshot = await _collection.get();

    return snapshot.docs
        .map((doc) => MealRecord.fromJson(doc.id, doc.data()))
        .toList();
  }

  /// UPDATE
  @override
  Future<void> updateMeal(MealRecord meal) async {
    await _collection.doc(meal.id).update(meal.toJson());
  }

  /// DELETE
  @override
  Future<void> deleteMeal(String id) async {
    await _collection.doc(id).delete();
  }
}
