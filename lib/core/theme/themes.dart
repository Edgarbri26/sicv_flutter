import 'package:flutter/material.dart';
import 'app_sizes.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class Themes {
  Themes._();

  // Tema por defecto
  static ThemeData defaultTheme = ThemeData(
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    scaffoldBackgroundColor: AppColors.secondary,

    appBarTheme: AppBarTheme(
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
        // 3. AJUSTE: 'AppTextStyles.bodyMedium' tampoco es 'const'
        textStyle: AppTextStyles.bodyMedium,
      ),
    ),

    // 3. AJUSTE: Se quitó 'const'
    inputDecorationTheme: InputDecorationTheme(
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
      hintStyle: AppTextStyles.bodySmall, // <-- 'final', no 'const'
      labelStyle: AppTextStyles.bodyMedium, // <-- 'final', no 'const'
    ),

    // 3. AJUSTE: Se quitó 'const'
    textTheme: TextTheme(
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

  // Tema Oscuro
  static ThemeData darkTheme = ThemeData(
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      surface: AppColors.surfaceDark,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.textPrimaryDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.headlineLarge.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, AppSizes.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusM),
        ),
        textStyle: AppTextStyles.bodyMedium,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.secondaryDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppSizes.borderRadiusM)),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppSizes.borderRadiusM)),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      contentPadding: EdgeInsets.symmetric(
        vertical: AppSizes.spacingS,
        horizontal: AppSizes.spacingM,
      ),
      hintStyle: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textSecondaryDark,
      ),
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textPrimaryDark,
      ),
    ),

    textTheme: TextTheme(
      displayMedium: AppTextStyles.displayMedium.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      displaySmall: AppTextStyles.displaySmall.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      bodySmall: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textSecondaryDark,
      ),
      labelSmall: AppTextStyles.labelSmall.copyWith(
        color: AppColors.textSecondaryDark,
      ),
    ),

    iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
    dividerColor: AppColors.borderDark,
    cardColor: AppColors.surfaceDark,
  );
}
