import 'package:dangdang/core/ai/gemini/gemini_client.dart';
import 'package:dangdang/core/utils/parsers/value_parser.dart';
import 'package:dangdang/features/meal/data/prompts/food_refine_prompt.dart';
import 'package:dangdang/features/meal/data/prompts/meal_analysis_prompt.dart';
import 'package:dangdang/features/meal/domain/entities/food_item.dart';
import 'package:dangdang/features/meal/domain/entities/meal_record.dart';
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

  FoodItem _mapFoodItem(dynamic value) {
    final item = value as Map<String, dynamic>;

    return FoodItem(
      name: item['name'] ?? '',
      amountLabel: item['amountLabel'] ?? '1인분',
      servingCount: parseDouble(item['servingCount'], defaultValue: 1.0),
      calories: parseDouble(item['calories']),
      carbohydrate: parseDouble(item['carbohydrate']),
      protein: parseDouble(item['protein']),
      fat: parseDouble(item['fat']),
      sugar: parseDouble(item['sugar']),
    );
  }
}
