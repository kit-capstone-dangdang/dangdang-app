import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
    await _firestore.collection('users').doc(_uid).update({
      'name': name,
      'nickname': nickname,
      'birthDate': birthDate,
      'gender': gender,
      'height': height,
      'weight': weight,
      'diabetesType': diabetesType,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProfileImageUrl(String profileImageUrl) async {
    await _firestore.collection('users').doc(_uid).update({
      'profileImageUrl': profileImageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
