import 'package:flutter/material.dart';
import 'package:sicv_flutter/models/product_model.dart';
import 'package:sicv_flutter/ui/widgets/img_product.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_sizes.dart';
import 'package:sicv_flutter/ui/widgets/info_chip.dart';

class ProductCard extends StatelessWidget {
    final ProductModel product;
    final bool isOutOfStock;
    final VoidCallback onTap;
    final VoidCallback onLongPress;

    const ProductCard({
      super.key, 
      required this.product, 
      required this.isOutOfStock,
      required this.onTap,
      required this.onLongPress
    });

    @override
    Widget build(BuildContext context) {
      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusL),
          border: Border.all(color: AppColors.border, width: 2),
        ),
        child: InkWell(
          onLongPress: onLongPress,
          onTap: isOutOfStock ? null : onTap,
          child: Opacity(
            opacity: isOutOfStock ? 0.5 : 1.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: ImgProduct(imageUrl: product.imageUrl ?? ''),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        InfoChip(
                          text: 'S/ ${product.price.toStringAsFixed(2)}',
                          color: AppColors.info,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }