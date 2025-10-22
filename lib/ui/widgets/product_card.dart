import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_text_styles.dart';
import 'package:sicv_flutter/ui/widgets/Info_chip.dart';
import '../../models/inventory_item.dart';

class ProductCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  late Color colorStock;
  late Color colorPrice;
  final Widget? trailing;

  ProductCard({
    required this.item,
    required this.onTap,
    required this.onDelete,
    this.trailing,
    super.key,
  }) {
    if (item.quantity > 10) {
      colorStock = AppColors.success;
    } else if (item.quantity > 0) {
      colorStock = AppColors.edit;
    } else {
      colorStock = AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      child: ListTile(
        style: ListTileStyle.list,
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.inventory_2, color: AppColors.primary),
        ),
        title: Text(item.name, style: AppTextStyles.bodyMediumBold),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.description, style: AppTextStyles.bodySmall),
            SizedBox(height: 4),
            Row(
              children: [
                InfoChip(text: '${item.quantity} unidades', color: colorStock),
                SizedBox(width: 8),
                InfoChip(
                  text: '\$${item.price.toStringAsFixed(2)}',
                  color: AppColors.info,
                ),
              ],
            ),
          ],
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  //   Widget _buildInfoChip(String text, Color color) {
  //     return Container(
  //       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  //       decoration: BoxDecoration(
  //         color: color.withOpacity(0.1),
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(color: color.withOpacity(0.3)),
  //       ),
  //       child: Text(
  //         text,
  //         style: TextStyle(
  //           fontSize: 12,
  //           color: color,
  //           fontWeight: FontWeight.w500,
  //         ),
  //       ),
  //     );
  //   }
}
