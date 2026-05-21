import 'package:flutter/material.dart';
import 'package:dangdang/features/meal/domain/entities/food_item.dart';

class FoodItemCard extends StatelessWidget {
  final FoodItem item;
  final double quantity;
  final Function(double) onChanged;
  final Function(String)? onNameChanged;
  final bool isUpdating;

  const FoodItemCard({
    super.key,
    required this.item,
    required this.quantity,
    required this.onChanged,
    this.onNameChanged,
    this.isUpdating = false,
  });

  Future<void> _showEditNameDialog(BuildContext context) async {
    final controller = TextEditingController(text: item.name);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('음식명 수정'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '음식명을 입력하세요'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('확인', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty && onNameChanged != null) {
      onNameChanged!(result.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseCalories = item.calories;
    final currentCalories = baseCalories * quantity;
    final unit = item.amountLabel.replaceAll(RegExp(r'[0-9.]'), '').trim();

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
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: isUpdating ? null : () => _showEditNameDialog(context),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (isUpdating) ...[
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '분석 중',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ] else ...[
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
                  ],
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.grey,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F0FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                        text: unit.isEmpty ? '인분' : unit,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
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
