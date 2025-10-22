import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_sizes.dart';
import 'package:sicv_flutter/core/theme/app_text_styles.dart';
import 'package:sicv_flutter/models/inventory_item.dart';
import 'package:sicv_flutter/ui/widgets/Info_chip.dart';

class DetailProductCart extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Widget? trailing;

  DetailProductCart({
    required this.item,
    required this.onTap,
    required this.onDelete,
    this.trailing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: AppSizes.spacingS),
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.spacingM,
        vertical: AppSizes.spacingM,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        spacing: AppSizes.spacingM,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.inventory_2, color: AppColors.primary),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: AppTextStyles.bodyMediumBold),
                Row(
                  spacing: AppSizes.spacingXXS,
                  children: [
                    InfoChip(
                      text: '${item.quantity} Uds.',
                      color: AppColors.info,
                    ),
                    InfoChip(
                      text: '${item.price.toStringAsFixed(2)}',
                      color: AppColors.info,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text("${(item.price * item.quantity).toStringAsFixed(2)}"),
          Row(
            spacing: 0,
            children: [
              IconButton(
                onPressed: onTap,
                icon: Icon(Icons.edit),
                color: AppColors.edit,
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete),
                color: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
