import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dangdang/features/auth/domain/entities/user.dart';
import 'package:dangdang/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class FirebaseAuthRepository implements AuthRepository {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on auth.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('이미 사용 중인 이메일입니다.');
      }

      if (e.code == 'weak-password') {
        throw Exception('비밀번호는 6자리 이상 입력해 주세요.');
      }

      if (e.code == 'invalid-email') {
        throw Exception('올바른 이메일 형식이 아닙니다.');
      }

      throw Exception('회원가입 중 오류가 발생했습니다.');
    }
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('가입된 이메일이 없습니다.');
      }

      if (e.code == 'wrong-password') {
        throw Exception('비밀번호가 올바르지 않습니다.');
      }

      if (e.code == 'invalid-email') {
        throw Exception('올바른 이메일 형식이 아닙니다.');
      }

      if (e.code == 'invalid-credential') {
        throw Exception('이메일 또는 비밀번호가 올바르지 않습니다.');
      }

      throw Exception('로그인 중 오류가 발생했습니다.');
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
