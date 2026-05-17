import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAccountRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> deleteAccount({required String currentPassword}) async {
    final user = _auth.currentUser;

    if (user == null || user.email == null) {
      throw Exception('로그인이 필요합니다.');
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);

    final uid = user.uid;

    await _deleteMealRecords(uid);
    await _deleteBloodGlucoseRecords(uid);

    await _firestore.collection('users').doc(uid).delete();

    await user.delete();
  }

  Future<void> _deleteMealRecords(String uid) async {
    final snapshot = await _firestore
        .collection('meal_records')
        .where('uid', isEqualTo: uid)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> _deleteBloodGlucoseRecords(String uid) async {
    final snapshot = await _firestore
        .collection('blood_glucose_records')
        .where('uid', isEqualTo: uid)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
