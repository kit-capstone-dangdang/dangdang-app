import 'package:dangdang/features/ai_chat/data/services/ai_chat_service.dart';
import 'package:dangdang/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:dangdang/features/blood_glucose/data/repositories/firebase_blood_glucose_repository.dart';
import 'package:dangdang/features/blood_glucose/data/services/blood_glucose_ai_service.dart';
import 'package:dangdang/features/meal/data/repositories/firebase_meal_repository.dart';
import 'package:dangdang/features/meal/data/services/image_picker_service.dart';
import 'package:dangdang/features/meal/data/services/meal_ai_service.dart';
import 'package:dangdang/features/meal/data/services/meal_image_storage_service.dart';
import 'package:dangdang/features/profile/data/repositories/firebase_account_repository.dart';
import 'package:dangdang/features/profile/data/repositories/firebase_profile_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final authRepositoryProvider = Provider<FirebaseAuthRepository>((ref) {
  return FirebaseAuthRepository();
});

final bloodGlucoseRepositoryProvider = Provider<FirebaseBloodSugarRepository>((
  ref,
) {
  return FirebaseBloodSugarRepository();
});

final mealRepositoryProvider = Provider<FirebaseMealRepository>((ref) {
  return FirebaseMealRepository();
});

final profileRepositoryProvider = Provider<FirebaseProfileRepository>((ref) {
  return FirebaseProfileRepository();
});

final accountRepositoryProvider = Provider<FirebaseAccountRepository>((ref) {
  return FirebaseAccountRepository();
});

final bloodGlucoseAiServiceProvider = Provider<BloodGlucoseAIService>((ref) {
  return BloodGlucoseAIService();
});

final mealAiServiceProvider = Provider<MealAiService>((ref) {
  return MealAiService();
});

final imagePickerServiceProvider = Provider<ImagePickerService>((ref) {
  return ImagePickerService();
});

final mealImageStorageServiceProvider = Provider<MealImageStorageService>((
  ref,
) {
  return MealImageStorageService();
});

final aiChatServiceProvider = Provider<AiChatService>((ref) {
  return AiChatService(
    bloodSugarRepository: ref.watch(bloodGlucoseRepositoryProvider),
    mealRepository: ref.watch(mealRepositoryProvider),
    profileRepository: ref.watch(profileRepositoryProvider),
  );
});
