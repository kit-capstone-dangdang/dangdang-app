class FoodAnalysisResult {
  const FoodAnalysisResult({
    required this.mealLabel,
    required this.capturedAt,
    required this.foodName,
    required this.totalCalories,
    required this.carbohydrates,
    required this.protein,
    required this.fat,
    required this.sugar,
    required this.items,
    required this.aiComment,
  });

  final String mealLabel;
  final String capturedAt;
  final String foodName;
  final int totalCalories;
  final int carbohydrates;
  final int protein;
  final int fat;
  final int sugar;
  final List<FoodAnalysisItem> items;
  final String aiComment;
}

class FoodAnalysisItem {
  const FoodAnalysisItem({
    required this.name,
    required this.servingText,
    required this.calories,
  });

  final String name;
  final String servingText;
  final int calories;
}
