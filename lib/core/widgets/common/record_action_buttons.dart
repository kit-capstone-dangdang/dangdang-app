import 'package:dangdang/core/widgets/common/custom_icon.dart';
import 'package:flutter/material.dart';

class RecordActionButtons
    extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  final Color? iconColor;
  final double size;
  final double spacing;

  const RecordActionButtons({
    super.key,
    this.onEdit,
    this.onDelete,
    this.iconColor,
    this.size = 24,
    this.spacing = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,

      children: [
        CustomIcon(
          icon: Icons.edit_outlined,
          size: size,
          iconColor:
              iconColor ??
              Colors.grey.shade400,
          onPressed: onEdit,
        ),

        SizedBox(width: spacing),

        CustomIcon(
          icon: Icons.delete_outlined,
          size: size,
          iconColor:
              iconColor ??
              Colors.grey.shade400,
          onPressed: onDelete,
        ),
      ],
    );
  }
}