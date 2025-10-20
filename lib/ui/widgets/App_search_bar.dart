import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_sizes.dart';

class AppSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final String hintText;
  const AppSearchBar({
    super.key,
    required this.searchController,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingM,
        vertical: 8,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingM,
        vertical: 0,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: searchController,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(Icons.search, color: AppColors.primary),
          hintStyle: TextStyle(
            fontSize: AppSizes.bodyM,
            fontWeight: FontWeight.normal,
            color: AppColors.textSecondary,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSizes.spacingM,
            vertical: AppSizes.spacingXS,
          ),
        ),
      ),
    );
  }
}
