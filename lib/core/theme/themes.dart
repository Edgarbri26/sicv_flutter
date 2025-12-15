import 'package:flutter/material.dart';
import 'app_sizes.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class Themes {
  Themes._();

  // ---------------------------------------------------------------------------
  // TEMA CLARO (LIGHT)
  // ---------------------------------------------------------------------------
  static ThemeData defaultTheme = ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      // Forzamos el fondo blanco en superficies para evitar tintes rosados de Material 3
      surface: AppColors.secondary,
    ),

    // 1. CAMBIO CLAVE: Fondo Gris Azulado (#F1F5F9)
    scaffoldBackgroundColor: AppColors.background,

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.secondary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.headlineLarge.copyWith(
        color: AppColors.secondary,
      ),
      iconTheme: const IconThemeData(color: AppColors.secondary),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.secondary,
        minimumSize: Size(double.infinity, AppSizes.buttonHeight),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusM),
        ),
        textStyle: AppTextStyles.bodyMedium,
      ),
    ),

    // Inputs: Fondo blanco sobre el fondo gris de la pantalla
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.secondary, // Blanco
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppSizes.borderRadiusM)),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppSizes.borderRadiusM)),
        borderSide: const BorderSide(
          color: AppColors.border,
        ), // Borde gris suave
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppSizes.borderRadiusM)),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(
        vertical: AppSizes.spacingS,
        horizontal: AppSizes.spacingM,
      ),
      hintStyle: AppTextStyles.bodySmall,
      labelStyle: AppTextStyles.bodyMedium,
    ),

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

    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
  );

  // ---------------------------------------------------------------------------
  // TEMA OSCURO (DARK)
  // ---------------------------------------------------------------------------
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      surface: AppColors.surfaceDark,
    ),

    // Fondo oscuro (#111827)
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
      fillColor: AppColors.secondaryDark, // Gris oscuro
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppSizes.borderRadiusM)),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppSizes.borderRadiusM)),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppSizes.borderRadiusM)),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
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
    dividerTheme: const DividerThemeData(
      color: AppColors.borderDark,
      thickness: 1,
    ),
  );
}
