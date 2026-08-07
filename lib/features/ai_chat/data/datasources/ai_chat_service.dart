import 'package:dangdang/core/ai/gemini/gemini_client.dart';
import 'package:dangdang/features/ai_chat/data/datasources/ai_chat_prompt.dart';
import 'package:dangdang/features/ai_chat/domain/entities/ai_chat_message.dart';
import 'package:dangdang/features/ai_chat/domain/entities/ai_chat_reply.dart';
import 'package:dangdang/features/blood_glucose/data/repositories/firebase_blood_glucose_repository.dart';
import 'package:dangdang/features/blood_glucose/domain/entities/blood_glucose_record.dart';
import 'package:dangdang/features/meal/data/repositories/firebase_meal_repository.dart';
import 'package:dangdang/features/meal/domain/entities/meal_record.dart';
import 'package:dangdang/features/profile/data/repositories/firebase_profile_repository.dart';

class AiChatService {
  final GeminiClient _geminiClient;
  final FirebaseBloodSugarRepository _bloodSugarRepository;
  final FirebaseMealRepository _mealRepository;
  final FirebaseProfileRepository _profileRepository;

  AiChatService({
    GeminiClient? geminiClient,
    FirebaseBloodSugarRepository? bloodSugarRepository,
    FirebaseMealRepository? mealRepository,
    FirebaseProfileRepository? profileRepository,
  }) : _geminiClient = geminiClient ?? GeminiClient(),
       _bloodSugarRepository =
           bloodSugarRepository ?? FirebaseBloodSugarRepository(),
       _mealRepository = mealRepository ?? FirebaseMealRepository(),
       _profileRepository = profileRepository ?? FirebaseProfileRepository();

  Future<AiChatReply> askQuestion({
    required String question,
    required List<AiChatMessage> conversation,
  }) async {
    final profile = await _safeGetProfile();
    final bloodSugarRecords = await _safeGetBloodSugarRecords();
    final mealRecords = await _safeGetMealRecords();

    final prompt = buildAiChatPrompt(
      profile: _buildProfilePayload(profile),
      bloodSugarRecords: _buildBloodSugarPayload(bloodSugarRecords),
      mealRecords: _buildMealPayload(mealRecords),
      conversationHistory: _buildConversationPayload(conversation),
      userQuestion: question,
    );

    final responseText = await _geminiClient.generateText(prompt);

    try {
      final decoded = _geminiClient.decodeJsonObject(responseText);
      final reply = AiChatReply.fromJson(decoded);

      if (reply.answer.isEmpty) {
        throw Exception('empty answer');
      }

      final normalizedSuggestions = _normalizeSuggestedQuestions(
        reply.suggestedQuestions,
      );

      return AiChatReply(
        answer: reply.answer,
        suggestedQuestions: normalizedSuggestions.isEmpty
            ? _fallbackSuggestions()
            : normalizedSuggestions,
      );
    } catch (_) {
      return AiChatReply(
        answer: responseText.trim(),
        suggestedQuestions: _fallbackSuggestions(),
      );
    }
  }

  Future<Map<String, dynamic>?> _safeGetProfile() async {
    try {
      return await _profileRepository.getProfile();
    } catch (_) {
      return null;
    }
  }

  Future<List<BloodGlucoseRecord>> _safeGetBloodSugarRecords() async {
    try {
      final records = await _bloodSugarRepository.getRecords();
      return records.take(14).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<MealRecord>> _safeGetMealRecords() async {
    try {
      final meals = await _mealRepository.getMeals();
      return meals.take(10).toList();
    } catch (_) {
      return [];
    }
  }

  Map<String, dynamic>? _buildProfilePayload(Map<String, dynamic>? profile) {
    if (profile == null) return null;

    return {
      'nickname': profile['nickname'],
      'birthDate': profile['birthDate'],
      'gender': profile['gender'],
      'height': profile['height'],
      'weight': profile['weight'],
      'diabetesType': profile['diabetesType'],
    };
  }

  List<Map<String, dynamic>> _buildBloodSugarPayload(
    List<BloodGlucoseRecord> records,
  ) {
    return records.map((record) {
      return {
        'dateTime': record.dateTime.toIso8601String(),
        'bloodSugar': record.bloodSugar,
        'mealState': record.mealState,
        'memo': record.memo,
      };
    }).toList();
  }

  List<Map<String, dynamic>> _buildMealPayload(List<MealRecord> meals) {
    return meals.map((meal) {
      return {
        'dateTime': meal.dateTime.toIso8601String(),
        'mealType': meal.mealType,
        'foods': meal.foods.map((food) => food.toJson()).toList(),
        'totalNutrition': meal.totalNutrition,
        'aiComment': meal.aiComment,
      };
    }).toList();
  }

  List<Map<String, dynamic>> _buildConversationPayload(
    List<AiChatMessage> conversation,
  ) {
    final start = conversation.length > 8 ? conversation.length - 8 : 0;
    final recentConversation = conversation.sublist(start);

    return recentConversation.map((message) => message.toPromptJson()).toList();
  }

  List<String> _normalizeSuggestedQuestions(List<String> questions) {
    return questions
        .map((question) => question.trim())
        .where((question) => question.isNotEmpty)
        .map(_shortenQuestion)
        .take(3)
        .toList();
  }

  String _shortenQuestion(String question) {
    if (question.length <= 18) {
      return question;
    }

    final shortened = question.substring(0, 18).trimRight();

    if (shortened.endsWith('?')) {
      return shortened;
    }

    return '$shortened...';
  }

  List<String> _fallbackSuggestions() {
    return const ['혈당 패턴 봐줘', '식단 문제점 알려줘', '공복 혈당 낮추려면?'];
  }
}