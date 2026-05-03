class FoodItem {
  final String name;
  final double amount; // 중요 (수량)
  final double calories;
  final double carbs;
  final double protein;
  final double fat;

  FoodItem({
    required this.name,
    required this.amount,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
  });
}