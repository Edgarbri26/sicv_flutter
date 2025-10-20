import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_sizes.dart';

class InventoryCard extends StatelessWidget {
  final String title;
  final Color statusColor;

  const InventoryCard({
    super.key,
    required this.title,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingM),
      margin: const EdgeInsets.only(bottom: AppSizes.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusM),
        border: Border.all(color: statusColor, width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.inventory, color: statusColor),
          const SizedBox(width: AppSizes.spacingM),
          Text(title, style: AppTextStyles.bodyLarge),
        ],
      ),
    );
  }
}
