import 'package:dangdang/core/widgets/common/custom_card.dart';
import 'package:dangdang/features/meal/domain/entities/food_item.dart';
import 'package:flutter/material.dart';

class FoodDetailItemCard extends StatefulWidget {
  final FoodItem item;
  final bool initiallyExpanded;

  const FoodDetailItemCard({
    super.key,
    required this.item,
    this.initiallyExpanded = false,
  });

  @override
  State<FoodDetailItemCard> createState() => _FoodDetailItemCardState();
}

class _FoodDetailItemCardState extends State<FoodDetailItemCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  Widget _buildNutritionItem({
    required BuildContext context,
    required String label,
    required String value,
    Color? labelColor,
    Color? valueColor,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final resolvedLabelColor = labelColor ?? Colors.grey.shade500;
    final resolvedValueColor = valueColor ?? Colors.black87;
    final unitIndex = value.endsWith('g') ? value.length - 1 : -1;
    final valueText = unitIndex > 0 ? value.substring(0, unitIndex) : value;
    final unitText = unitIndex > 0 ? value.substring(unitIndex) : '';

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: resolvedLabelColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: valueText,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: resolvedValueColor,
                    ),
                  ),
                  TextSpan(
                    text: unitText,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: resolvedValueColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final item = widget.item;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: CustomCard(
        onTap: _toggleExpanded,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.amountLabel,
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w400,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_formatNumber(item.calories)} kcal',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                Divider(color: Colors.grey.shade200, height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildNutritionItem(
                      context: context,
                      label: '탄수',
                      value: '${_formatNumber(item.carbohydrate)}g',
                    ),
                    const SizedBox(width: 10),
                    _buildNutritionItem(
                      context: context,
                      label: '단백',
                      value: '${_formatNumber(item.protein)}g',
                    ),
                    const SizedBox(width: 10),
                    _buildNutritionItem(
                      context: context,
                      label: '지방',
                      value: '${_formatNumber(item.fat)}g',
                    ),
                    const SizedBox(width: 10),
                    _buildNutritionItem(
                      context: context,
                      label: '당류',
                      value: '${_formatNumber(item.sugar)}g',
                      labelColor: const Color(0xFFFF6B6B),
                      valueColor: const Color(0xFFFF6B6B),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
