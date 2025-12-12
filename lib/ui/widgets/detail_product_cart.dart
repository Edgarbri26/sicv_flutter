import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_sizes.dart';
import 'package:sicv_flutter/core/theme/app_text_styles.dart';
import 'package:sicv_flutter/models/sale/sale_item_model.dart';
import 'package:sicv_flutter/ui/widgets/info_chip.dart';

class DetailProductCart extends StatelessWidget {
  final SaleItemModel item;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Widget? trailing;

  const DetailProductCart({
    required this.item,
    required this.onTap,
    required this.onDelete,
    this.trailing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(top: AppSizes.spacingS),
        padding: EdgeInsets.only(
          left: AppSizes.spacingM,
          right: AppSizes.spacingS,
          top: AppSizes.spacingM,
          bottom: AppSizes.spacingM,
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
                  Text(item.productName!, style: AppTextStyles.bodyMedium),
                  Row(
                    children: [
                      InfoChip(
                        text: '${item.amount} Uds',
                        color: AppColors.info,
                      ),
                      InfoChip(
                        text: '\$${item.unitCost.toStringAsFixed(2)}',
                        color: AppColors.info,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              spacing: 0,
              children: [
                Text('\$${(item.unitCost * item.amount).toStringAsFixed(2)}'),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete),
                  color: AppColors.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
