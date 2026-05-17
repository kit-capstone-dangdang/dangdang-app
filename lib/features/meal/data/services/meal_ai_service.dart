import 'dart:convert';

import 'package:dangdang/core/ai/gemini/gemini_client.dart';
import 'package:dangdang/core/utils/parsers/value_parser.dart';
import 'package:dangdang/features/meal/data/prompts/food_refine_prompt.dart';
import 'package:dangdang/features/meal/data/prompts/meal_analysis_prompt.dart';
import 'package:dangdang/features/meal/domain/entities/food_item.dart';
import 'package:dangdang/features/meal/domain/entities/meal_record.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class MealAiService {
  final GeminiClient _client;

  MealAiService({GeminiClient? client}) : _client = client ?? GeminiClient();

  Future<MealRecord> analyzeFoodImage({
    required XFile image,
    required String mealType,
    required DateTime dateTime,
    String id = '',
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final imageBytes = await image.readAsBytes();
    final responseText = await _client.generateTextFromImage(
      prompt: mealAnalysisPrompt,
      imageBytes: imageBytes,
    );
    final result = _client.decodeJsonObject(responseText);
    final foodsJson = result['foods'] as List<dynamic>? ?? [];
    final foods = foodsJson.map(_mapFoodItem).toList();

    return MealRecord(
      id: id,
      uid: uid,
      dateTime: dateTime,
      mealType: mealType,
      foods: foods,
      imageUrl: '',
      aiComment: result['aiComment'] ?? '',
      totalNutrition: MealRecord.totalNutritionFromFoods(foods),
    );
  }

  Future<List<FoodItem>> refineMultipleFoodsInfo(List<String> foodNames) async {
    if (foodNames.isEmpty) return [];

    final responseText = await _client.generateText(
      buildFoodRefinePrompt(foodNames),
    );
    final decoded = _client.decodeJsonArray(responseText);

    return decoded.map(_mapFoodItem).toList();
  }

  Future<MealHabitAnalysisResult> analyzeMealHabits({
    required List<MealRecord> records,
    required String scopeLabel,
    required String diabetesType,
  }) async {
    if (records.isEmpty) {
      return const MealHabitAnalysisResult(patterns: [], recommendations: []);
    }

    final mealRecordsJson = jsonEncode(
      records.map((record) => _buildMealRecordPayload(record)).toList(),
    );

    final responseText = await _client.generateText(
      buildMealHabitAnalysisPrompt(
        scopeLabel: scopeLabel,
        mealRecordsJson: mealRecordsJson,
        diabetesType: diabetesType,
      ),
    );

    final decoded = _client.decodeJsonObject(responseText);

    return MealHabitAnalysisResult(
      patterns: _readStringList(decoded['patterns']),
      recommendations: _readStringList(decoded['recommendations']),
    );
  }

  FoodItem _mapFoodItem(dynamic value) {
    final item = value as Map<String, dynamic>;
    final amountLabel = item['amountLabel'] ?? '1인분';

    return FoodItem(
      name: item['name'] ?? '',
      amountLabel: amountLabel,
      servingCount: parseServingCount(
        item['servingCount'],
        amountLabel: amountLabel.toString(),
        defaultValue: 1.0,
      ),
      calories: parseDouble(item['calories']),
      carbohydrate: parseDouble(item['carbohydrate']),
      protein: parseDouble(item['protein']),
      fat: parseDouble(item['fat']),
      sugar: parseDouble(item['sugar']),
    );
  }

  Map<String, dynamic> _buildMealRecordPayload(MealRecord record) {
    return {
      'date': record.dateTime.toIso8601String(),
      'mealType': record.mealType,
      'foods': record.foods.map((food) => food.toJson()).toList(),
      'totalNutrition': record.totalNutrition,
      'aiComment': record.aiComment,
    };
  }

  List<String> _readStringList(dynamic value) {
    final items = value as List<dynamic>? ?? const [];

    return items
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
}

class MealHabitAnalysisResult {
  const MealHabitAnalysisResult({
    required this.patterns,
    required this.recommendations,
  });

  final List<String> patterns;
  final List<String> recommendations;
}
