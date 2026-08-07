import 'package:dangdang/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<void> signUp({
    required String name,
    required String nickname,
    required String email,
    required String password,
    required String birthDate,
    required String gender,
    required int height,
    required int weight,
    required String diabetesType,
  });

  Future<void> signIn({required String email, required String password});

  Future<void> signOut();

  User? get currentUser;
}
