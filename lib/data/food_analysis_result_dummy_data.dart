import 'package:dangdang/model/food_analysis_result.dart';

const FoodAnalysisResult dummyFoodAnalysisResult = FoodAnalysisResult(
  mealLabel: '점심',
  capturedAt: '2026-03-26 12:30',
  foodName: '비빔밥, 된장국',
  totalCalories: 605,
  carbohydrates: 91,
  protein: 21,
  fat: 13,
  sugar: 14,
  items: [
    FoodAnalysisItem(name: '비빔밥', servingText: '1공기', calories: 560),
    FoodAnalysisItem(name: '된장국', servingText: '0.5그릇', calories: 45),
  ],
  aiComment:
      '채소 구성이 좋아 전체적으로 균형이 괜찮은 식사예요. 탄수화물과 단백질, 지방이 비교적 고르게 포함되어 있어 한 끼 식사로 적절합니다.',
);
