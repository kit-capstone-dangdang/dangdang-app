import 'package:dangdang/core/widgets/common/custom_card.dart';
import 'package:dangdang/core/widgets/common/custom_icon.dart';
import 'package:dangdang/features/blood_glucose/domain/entities/blood_glucose_record.dart';
import 'package:flutter/material.dart';

class BloodSugarRecordCard extends StatelessWidget {
  final BloodSugarRecord record;

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BloodSugarRecordCard({
    super.key,
    required this.record,
    this.onEdit,
    this.onDelete,
  });

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final Color valueColor = Theme.of(context).primaryColor;

    final Color bgColor = valueColor.withOpacity(0.08);

    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      borderRadius: 28,
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${record.bloodSugar}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: valueColor,
                  ),
                ),
                Text(
                  'mg/dL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      record.mealState,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(record.dateTime),
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  record.memo,
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                ),
              ],
            ),
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIcon(
                icon: Icons.edit_outlined,
                size: 24,
                iconColor: Colors.grey.shade400,
                onPressed: onEdit,
              ),
              const SizedBox(width: 6),
              CustomIcon(
                icon: Icons.delete_outlined,
                size: 24,
                iconColor: Colors.grey.shade400,
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
