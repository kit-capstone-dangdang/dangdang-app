import 'package:flutter/material.dart';

class NutritionSummaryBox extends StatelessWidget {
  final int calories;
  final int carbohydrate;
  final int protein;
  final int fat;
  final int sugar;

  const NutritionSummaryBox({
    super.key,
    required this.calories,
    required this.carbohydrate,
    required this.protein,
    required this.fat,
    required this.sugar,
  });

  Widget _nutrientItem(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '총 영양 정보 합계',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Text(
                    calories.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('kcal', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _nutrientItem('탄수', '${carbohydrate}g'),
              _nutrientItem('단백', '${protein}g'),
              _nutrientItem('지방', '${fat}g'),
              _nutrientItem('당류', '${sugar}g'),
            ],
          ),
        ],
      ),
    );
  }
}
