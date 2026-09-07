import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseAccountRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String _nicknameDocId(String nickname) => nickname.trim().toLowerCase();

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
    final userSnapshot = await _firestore.collection('users').doc(uid).get();
    final nickname = userSnapshot.data()?['nickname']?.toString() ?? '';

    await _deleteMealRecords(uid);
    await _deleteBloodGlucoseRecords(uid);
    await _deleteProfileImage(uid);

    if (nickname.trim().isNotEmpty) {
      await _firestore
          .collection('nicknames')
          .doc(_nicknameDocId(nickname))
          .delete();
    }

    await _firestore.collection('users').doc(uid).delete();

    await user.delete();
  }

  Future<void> _deleteMealRecords(String uid) async {
    final snapshot = await _firestore
        .collection('meal_record')
        .where('uid', isEqualTo: uid)
        .get();

    for (final doc in snapshot.docs) {
      final imageUrl = doc.data()['imageUrl']?.toString() ?? '';
      await doc.reference.delete();

      if (imageUrl.isNotEmpty) {
        try {
          final storageRef = _storage.refFromURL(imageUrl);
          await storageRef.delete();
        } catch (e) {
          print('스토리지 이미지 삭제 실패 (무시됨): $e');
        }
      }
    }
  }

  Future<void> _deleteBloodGlucoseRecords(String uid) async {
    final snapshot = await _firestore
        .collection('blood_glucose_record')
        .where('uid', isEqualTo: uid)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> _deleteProfileImage(String uid) async {
    try {
      final storageRef = _storage.ref().child('profile_images').child('$uid.jpg');
      await storageRef.delete();
    } catch (e) {
      print('프로필 이미지 삭제 실패 (무시됨): $e');
    }
  }
}
