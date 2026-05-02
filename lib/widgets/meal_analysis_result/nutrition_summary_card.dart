import 'package:flutter/material.dart';
import '../common/custom_card.dart';

class NutritionSummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const NutritionSummaryCard({
    super.key,
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CustomCard(
      //padding: const EdgeInsets.all(18),
      backgroundColor: isHighlight
          ? const Color.fromARGB(255, 253, 232, 232)
          : Colors.grey[100]!,
      child: Column(
        children: [
          Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              color: isHighlight ? Colors.red : Colors.grey,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: textTheme.bodyLarge?.copyWith(
              color: isHighlight ? Colors.red : Colors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
