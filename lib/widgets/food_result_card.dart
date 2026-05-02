import 'package:flutter/material.dart';

class FoodResultCard extends StatefulWidget {
  final String foodName;
  final double initialPortion;
  final int baseCalories;

  const FoodResultCard({
    super.key,
    required this.foodName,
    this.initialPortion = 1.0,
    required this.baseCalories,
  });

  @override
  State<FoodResultCard> createState() => _FoodResultCardState();
}

// ==========================================
// 식단 (0.1인분 조절 로직)
// ==========================================
class _FoodResultCardState extends State<FoodResultCard> {
  late double _currentPortion;

  @override
  void initState() {
    super.initState();
    _currentPortion = widget.initialPortion;
  }

  void _decreasePortion() {
    if (_currentPortion > 0.1) {
      setState(() {
        _currentPortion = double.parse(
          (_currentPortion - 0.1).toStringAsFixed(1),
        );
      });
    }
  }

  void _increasePortion() {
    setState(() {
      _currentPortion = double.parse(
        (_currentPortion + 0.1).toStringAsFixed(1),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final int totalCalories = (widget.baseCalories * _currentPortion).round();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.foodName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$totalCalories kcal",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 20),
                    onPressed: _currentPortion > 0.1 ? _decreasePortion : null,
                    color: const Color(0xFF2F69FE),
                  ),
                  Text(
                    "${_currentPortion.toStringAsFixed(1)}인분",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 20),
                    onPressed: _increasePortion,
                    color: const Color(0xFF2F69FE),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
