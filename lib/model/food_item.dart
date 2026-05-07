class FoodItem {
  final String name;
  final double amount;
  final double calories;
  final double carbs;
  final double protein;
  final double fat;
  final double sugar;

  FoodItem({
    required this.name,
    required this.amount,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.sugar
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'calories': calories,
      'carbs': carbs,
      'protein': protein,
      'fat': fat,
      'sugar': sugar,
    };
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'],
      amount: (json['amount'] ?? 1).toDouble(),
      calories: (json['calories'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      sugar: (json['sugar'] ?? 0).toDouble(),
    );
  }
}