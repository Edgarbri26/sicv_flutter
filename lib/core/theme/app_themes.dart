import 'package:flutter/material.dart';
import 'app_sizes.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
// 1. ELIMINADO: No necesitas importar 'google_fonts' aquí.
//    Se importa en 'app_text_styles.dart'.

class Themes {
  Themes._();

  // Tema por defecto
  static ThemeData defaultTheme = ThemeData(
    // 2. ELIMINADO: Esta línea es redundante.
    //    La fuente ya está definida en tu 'textTheme'.
    // fontFamily: 'Inter', 
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.secondary,

    // 3. AJUSTE: Se quitó 'const'
    //    Porque 'AppTextStyles.headlineLarge' ya no es 'const'
    //    (ahora usa GoogleFonts, que es 'final').
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
}