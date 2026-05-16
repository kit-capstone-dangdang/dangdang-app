import 'package:flutter/material.dart';

class RecordRangeDropdown<T> extends StatelessWidget {
  final List<T> values;
  final T selectedValue;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onSelected;

  const RecordRangeDropdown({
    super.key,
    required this.values,
    required this.selectedValue,
    required this.labelBuilder,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: values.map((value) {
          final isSelected = value == selectedValue;

          return InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => onSelected(value),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      labelBuilder(value),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF5A46F5)
                            : const Color(0xFF4D5566),
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF5A46F5),
                      size: 24,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
