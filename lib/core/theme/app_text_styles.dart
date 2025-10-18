import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_sizes.dart';

class AppTextStyles {
  AppTextStyles._(); // Evita instanciación

  // 🧱 Titulares
  static const displayMedium = TextStyle(
    fontSize: AppSizes.displayL,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const displaySmall = TextStyle(
    fontSize: AppSizes.displayM,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // 📰 Encabezados
  static const headlineLarge = TextStyle(
    fontSize: AppSizes.headlineL,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const headlineMedium = TextStyle(
    fontSize: AppSizes.headlineM,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // 📋 Texto principal
  static const bodyLarge = TextStyle(
    fontSize: AppSizes.bodyL,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const bodyMedium = TextStyle(
    fontSize: AppSizes.bodyM,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const bodySmall = TextStyle(
    fontSize: AppSizes.bodyS,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // 🏷️ Etiquetas y estados
  static const labelSmall = TextStyle(
    fontSize: AppSizes.labelS,
    fontWeight: FontWeight.w500,
    color: AppColors.iconPassive,
  );
}