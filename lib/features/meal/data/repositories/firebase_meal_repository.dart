import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dangdang/features/meal/domain/entities/meal_record.dart';
import 'package:dangdang/features/meal/domain/repositories/meal_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseMealRepository implements MealRepository {
  final _collection = FirebaseFirestore.instance.collection('meal_record');
  final _storage = FirebaseStorage.instance;

  String get _uid {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      throw Exception('로그인이 필요합니다.');
    }

    return uid;
  }

  @override
  Future<void> createMeal(MealRecord meal) async {
    await _collection.add(meal.toJson());
  }

  @override
  Future<List<MealRecord>> getMeals() async {
    final snapshot = await _collection
        .where('uid', isEqualTo: _uid)
        .orderBy('dateTime', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => MealRecord.fromJson(doc.id, doc.data()))
        .toList();
  }

  @override
  Stream<List<MealRecord>> watchMeals() {
    return _collection
        .where('uid', isEqualTo: _uid)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MealRecord.fromJson(doc.id, doc.data()))
              .toList();
        });
  }

  @override
  Stream<MealRecord?> watchMeal(String id) {
    return _collection.doc(id).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.data();
      if (data == null || data['uid'] != _uid) {
        return null;
      }

      return MealRecord.fromJson(snapshot.id, data);
    });
  }

  @override
  Future<void> updateMeal(MealRecord meal, {String? oldImageUrl}) async {
    await _collection.doc(meal.id).update(meal.toJson());

    if (oldImageUrl != null &&
        oldImageUrl.isNotEmpty &&
        oldImageUrl != meal.imageUrl) {
      try {
        final storageRef = _storage.refFromURL(oldImageUrl);
        await storageRef.delete();
        print('이전 이미지 파일 삭제 완료');
      } catch (e) {
        print('이전 스토리지 이미지 삭제 실패 (무시됨): $e');
      }
    }
  }

  @override
  Future<void> deleteMeal(String id, {String? imageUrl}) async {
    try {
      await _collection.doc(id).delete();

      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          final storageRef = _storage.refFromURL(imageUrl);
          await storageRef.delete();
        } catch (e) {
          print('스토리지 이미지 삭제 실패 (무시됨): $e');
        }
      }
    } catch (e) {
      print('식단 삭제 실패: $e');
      rethrow;
    }
  }
}
