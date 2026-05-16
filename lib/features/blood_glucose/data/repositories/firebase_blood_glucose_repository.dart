import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dangdang/features/blood_glucose/domain/entities/blood_glucose_record.dart';
import 'package:dangdang/features/blood_glucose/domain/repositories/blood_glucose_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseBloodSugarRepository implements BloodSugarRepository {
  final _collection = FirebaseFirestore.instance.collection(
    'blood_glucose_record',
  );

  final _reportCollection = FirebaseFirestore.instance.collection(
    'blood_glucose_reports',
  );

  String get _uid {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      throw Exception('로그인이 필요합니다.');
    }

    return uid;
  }

  @override
  Future<void> createRecord(BloodGlucoseRecord record) async {
    await _collection.add(record.toJson());
  }

  @override
  Future<List<BloodGlucoseRecord>> getRecords() async {
    final snapshot = await _collection
        .where('uid', isEqualTo: _uid)
        .orderBy('dateTime', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return BloodGlucoseRecord.fromJson(doc.id, doc.data());
    }).toList();
  }

  @override
  Future<void> updateRecord(BloodGlucoseRecord record) async {
    await _collection.doc(record.id).update(record.toJson());
  }

  @override
  Future<void> deleteRecord(String id) async {
    await _collection.doc(id).delete();
  }

  @override
  Future<void> saveAiReport(String reportText) async {
    await _reportCollection.doc(_uid).set({
      'reportText': reportText,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<String?> getLatestAiReport() async {
    final doc = await _reportCollection.doc(_uid).get();

    if (doc.exists && doc.data() != null) {
      return doc.data()!['reportText'] as String?;
    }

    return null;
  }
}
