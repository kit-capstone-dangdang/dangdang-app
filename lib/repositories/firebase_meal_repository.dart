import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meal_record.dart';
import 'meal_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseMealRepository implements MealRepository {
  final _collection = FirebaseFirestore.instance.collection('meal_record');
  final _storage = FirebaseStorage.instance; // 추가

  /// CREATE
  @override
  Future<void> createMeal(MealRecord meal) async {
    await _collection.add(meal.toJson());
  }

  /// READ (한 번 조회)
  @override
  Future<List<MealRecord>> getMeals() async {
    final snapshot = await _collection.get();

    return snapshot.docs
        .map((doc) => MealRecord.fromJson(doc.id, doc.data()))
        .toList();
  }

  /// READ STREAM (실시간 조회) 추가
  Stream<List<MealRecord>> watchMeals() {
    return _collection.orderBy('dateTime', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => MealRecord.fromJson(doc.id, doc.data()))
          .toList();
    });
  }

  /// UPDATE
  @override
  Future<void> updateMeal(MealRecord meal, {String? oldImageUrl}) async {
    // 1. 파이어스토어 데이터 업데이트
    await _collection.doc(meal.id).update(meal.toJson());

    // 2. 이미지가 교체되었다면 스토리지에서 기존 이미지 삭제
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

  /// DELETE
  @override
  Future<void> deleteMeal(String id, {String? imageUrl}) async {
    try {
      // 1. 파이어스토어 문서 삭제
      await _collection.doc(id).delete();

      // 2. 파이어베이스 스토리지 이미지 삭제 (imageUrl이 존재하는 경우)
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          // 다운로드 URL을 이용해 스토리지 참조(reference)를 가져와서 삭제
          final storageRef = _storage.refFromURL(imageUrl);
          await storageRef.delete();
        } catch (e) {
          // 이미지가 이미 삭제되었거나 경로를 찾을 수 없는 경우의 예외 처리
          print('스토리지 이미지 삭제 실패 (무시됨): $e');
        }
      }
    } catch (e) {
      print('식단 삭제 실패: $e');
      rethrow; // UI 쪽에 에러를 던져서 스낵바를 띄울 수 있게 함
    }
  }
}
