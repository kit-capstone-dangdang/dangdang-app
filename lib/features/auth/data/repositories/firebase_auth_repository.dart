import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dangdang/features/auth/domain/entities/user.dart';
import 'package:dangdang/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';

class FirebaseAuthRepository implements AuthRepository {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Never _throwAuthException(String action, auth.FirebaseAuthException e) {
    debugPrint(
      '[FirebaseAuth][$action] code=${e.code}, message=${e.message}, email=${e.email}',
    );

    switch (e.code) {
      case 'email-already-in-use':
        throw Exception('이미 사용 중인 이메일입니다.');
      case 'weak-password':
        throw Exception('비밀번호는 6자리 이상 입력해 주세요.');
      case 'invalid-email':
        throw Exception('올바른 이메일 형식이 아닙니다.');
      case 'user-not-found':
        throw Exception('가입된 이메일이 없습니다.');
      case 'wrong-password':
      case 'invalid-credential':
        throw Exception('이메일 또는 비밀번호가 올바르지 않습니다.');
      case 'network-request-failed':
        throw Exception('네트워크 오류로 로그인에 실패했습니다. 인터넷 연결과 배포 도메인을 확인해 주세요.');
      case 'too-many-requests':
        throw Exception('요청이 너무 많아 잠시 차단되었습니다. 잠시 후 다시 시도해 주세요.');
      case 'operation-not-allowed':
        throw Exception('Firebase Authentication에서 이메일/비밀번호 로그인이 비활성화되어 있습니다.');
      case 'web-storage-unsupported':
        throw Exception('이 브라우저 환경에서는 로그인 저장소를 사용할 수 없습니다.');
      default:
        final detail = e.message == null ? e.code : '${e.code}: ${e.message}';
        throw Exception('$action 중 Firebase 오류가 발생했습니다. [$detail]');
    }
  }

  @override
  Future<void> signUp({
    required String name,
    required String nickname,
    required String email,
    required String password,
  }) async {
    final nicknameSnapshot = await _firestore
        .collection('users')
        .where('nickname', isEqualTo: nickname)
        .limit(1)
        .get();

    if (nicknameSnapshot.docs.isNotEmpty) {
      throw Exception('이미 사용 중인 닉네임입니다.');
    }

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception('회원가입에 실패했습니다.');
      }

      final user = User(
        uid: firebaseUser.uid,
        name: name,
        nickname: nickname,
        email: email,
      );

      await _firestore.collection('users').doc(firebaseUser.uid).set({
        ...user.toJson(),
        'birthDate': '',
        'gender': '',
        'height': 0,
        'weight': 0,
        'diabetesType': '',
        'profileImageUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on auth.FirebaseAuthException catch (e) {
      _throwAuthException('회원가입', e);
    }
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on auth.FirebaseAuthException catch (e) {
      _throwAuthException('로그인', e);
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  User? get currentUser {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      return null;
    }

    return User(
      uid: firebaseUser.uid,
      name: '',
      nickname: '',
      email: firebaseUser.email ?? '',
    );
  }
}
