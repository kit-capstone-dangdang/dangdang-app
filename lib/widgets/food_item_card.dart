import 'package:flutter/material.dart';
import '../model/food_analysis_result.dart';

class FoodItemCard extends StatelessWidget {
  final FoodAnalysisItem item;
  final double quantity;
  final Function(double) onChanged;

  const FoodItemCard({
    super.key,
    required this.item,
    required this.quantity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final baseCalories = item.calories.toDouble();
    final currentCalories = baseCalories * quantity;
    final unit =
        item.servingText.replaceAll(RegExp(r'[0-9.]'), '').trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  Text(
                    currentCalories.toStringAsFixed(0),
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('kcal'),

                  IconButton(
                    onPressed: () {
                      // TODO: 삭제 기능 연결 (부모에서 처리해야함)
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.grey,
                      size: 22,
                    ),
                  ),
                ],
              )
            ],
          ),

          const SizedBox(height: 16),

          // 수량 조절
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F0FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // - 버튼
                IconButton(
                  onPressed: () {
                    if (quantity > 0.1) {
                      onChanged(
                        double.parse((quantity - 0.1).toStringAsFixed(1)),
                      );
                    }
                  },
                  icon: const Icon(Icons.remove),
                ),

                // 수량
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${quantity.toStringAsFixed(1)} ',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: unit,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // + 버튼
                IconButton(
                  onPressed: () {
                    onChanged(
                      double.parse((quantity + 0.1).toStringAsFixed(1)),
                    );
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}