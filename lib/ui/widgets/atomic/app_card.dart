import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_sizes.dart';
import 'package:sicv_flutter/models/type_payment_model.dart';

class AppCard extends StatelessWidget {
  final String title;
  final String subTitle;
  final Widget? trailing;
  final Widget? leading;
  const AppCard({
    super.key,
    required this.title,
    required this.subTitle,
    this.trailing,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusM),
        border: Border.all(
          color: AppColors.border,
          style: BorderStyle.solid,
          width: 3,
        ),
      ),
      child: ListTile(
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingS),
          child: leading,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppSizes.bodyM,
          ),
        ),
        subtitle: Text(
          subTitle,
          style: const TextStyle(
            fontSize: AppSizes.bodyS,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: trailing,
      ),
    );
  }
}
