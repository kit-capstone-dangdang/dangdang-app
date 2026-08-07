import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _nicknameDocId(String nickname) => nickname.trim().toLowerCase();

  String get _uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('로그인이 필요합니다.');
    }

    return user.uid;
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final snapshot = await _firestore.collection('users').doc(_uid).get();

    return snapshot.data();
  }

  Future<void> updateProfile({
    required String name,
    required String nickname,
    required String birthDate,
    required String gender,
    required int height,
    required int weight,
    required String diabetesType,
  }) async {
    final normalizedNickname = _nicknameDocId(nickname);
    final userRef = _firestore.collection('users').doc(_uid);
    final newNicknameRef = _firestore
        .collection('nicknames')
        .doc(normalizedNickname);

    await _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final currentNickname =
          userSnapshot.data()?['nickname']?.toString().trim() ?? '';
      final currentNicknameDocId = _nicknameDocId(currentNickname);
      final newNicknameSnapshot = await transaction.get(newNicknameRef);

      if (currentNicknameDocId != normalizedNickname &&
          newNicknameSnapshot.exists &&
          newNicknameSnapshot.data()?['uid']?.toString() != _uid) {
        throw Exception('이미 사용 중인 닉네임입니다.');
      }

      transaction.set(newNicknameRef, {
        'uid': _uid,
        'nickname': nickname,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (currentNicknameDocId.isNotEmpty &&
          currentNicknameDocId != normalizedNickname) {
        transaction.delete(
          _firestore.collection('nicknames').doc(currentNicknameDocId),
        );
      }

      transaction.update(userRef, {
        'name': name,
        'nickname': nickname,
        'birthDate': birthDate,
        'gender': gender,
        'height': height,
        'weight': weight,
        'diabetesType': diabetesType,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> updateProfileImageUrl(String profileImageUrl) async {
    await _firestore.collection('users').doc(_uid).update({
      'profileImageUrl': profileImageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}