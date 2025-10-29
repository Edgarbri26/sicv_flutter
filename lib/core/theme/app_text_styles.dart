// lib/config/themes/app_text_styles.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // 1. Importa google_fonts
import 'app_colors.dart'; // (Asumo que tienes tus colores aquí)

class AppTextStyles {

  // 2. Define tu fuente base UNA SOLA VEZ
  //    Esto usa "Inter" como la fuente por defecto para todo.
  static final TextStyle _base = GoogleFonts.inter(
    color: AppColors.textPrimary, // Asigna un color de texto por defecto
  );

  // 3. Usa .copyWith() para crear todos tus estilos
  //    Esto toma la fuente "Inter" y solo cambia lo que necesitas.
  
  static final TextStyle displayMedium = _base.copyWith(
    fontSize: 45,
    fontWeight: FontWeight.w400,
  );
  
  static final TextStyle displaySmall = _base.copyWith(
    fontSize: 36,
    fontWeight: FontWeight.w400,
  );

  static final TextStyle headlineLarge = _base.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle headlineMedium = _base.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  
  static final TextStyle bodyLarge = _base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );
  
  static final TextStyle bodyMedium = _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );
  
  static final TextStyle bodySmall = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, // Un color diferente, por ejemplo
  );
  
  static final TextStyle labelSmall = _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  
}