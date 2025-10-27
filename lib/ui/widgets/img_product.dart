import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_sizes.dart';

class ImgProduct extends StatelessWidget {
  const ImgProduct({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
  });
  final String imageUrl;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.iconPassive.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusM),
      ),
      child: (imageUrl.isNotEmpty)
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: width,
              height: height,
            )
          : Icon(Icons.inventory_2, size: 40, color: Theme.of(context).colorScheme.primary),
    );
  }
}
