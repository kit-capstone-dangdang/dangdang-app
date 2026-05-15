import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dangdang/features/blood_glucose/domain/entities/blood_sugar_record.dart';
import 'blood_sugar_repository.dart';

class FirebaseBloodSugarRepository
    implements BloodSugarRepository {
  final _collection = FirebaseFirestore.instance
      .collection('blood_glucose_record');

  /// CREATE
  @override
  Future<void> createRecord(
    BloodSugarRecord record,
  ) async {
    await _collection.add(record.toJson());
  }

  /// READ
  @override
  Future<List<BloodSugarRecord>>
      getRecords() async {
    final snapshot = await _collection
    .orderBy('dateTime', descending: true)
    .get();

    return snapshot.docs.map((doc) {
      return BloodSugarRecord.fromJson(
        doc.id,
        doc.data(),
      );
    }).toList();
  }

  /// UPDATE
  @override
  Future<void> updateRecord(
    BloodSugarRecord record,
  ) async {
    await _collection
        .doc(record.id)
        .update(record.toJson());
  }

  /// DELETE
  @override
  Future<void> deleteRecord(String id) async {
    await _collection.doc(id).delete();
  }
}