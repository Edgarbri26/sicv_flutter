import 'package:flutter/material.dart';
import 'app_sizes.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class Themes {
  Themes._();

  // Tema por defecto
  static ThemeData defaultTheme = ThemeData(
    fontFamily: 'Inter',
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.secondary,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.secondary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.headlineLarge,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.secondary,
        minimumSize: Size(double.infinity, AppSizes.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusM),
        ),
        textStyle: AppTextStyles.bodyMedium,
      ),
    ),

    // Definición de estilos para campos de texto
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.secondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppSizes.borderRadiusM)),
        borderSide: BorderSide(color: AppColors.border),
      ),
      contentPadding: EdgeInsets.symmetric(
        vertical: AppSizes.spacingS,
        horizontal: AppSizes.spacingM,
      ),
      hintStyle: AppTextStyles.bodySmall,
      labelStyle: AppTextStyles.bodyMedium,
    ),

    // Definición de la tipografía global
    textTheme: const TextTheme(
      displayMedium: AppTextStyles.displayMedium,
      displaySmall: AppTextStyles.displaySmall,
      headlineLarge: AppTextStyles.headlineLarge,
      headlineMedium: AppTextStyles.headlineMedium,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelSmall: AppTextStyles.labelSmall,
    ),
  );
}
