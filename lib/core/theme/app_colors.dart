import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  /// Color principal de la aplicación.
  /// (Azul Pizarra Oscuro)
  static const Color primary = Color.fromARGB(255, 45, 63, 87);

  /// Color secundario, usado generalmente para SUPERFICIES (Tarjetas, Inputs).
  /// Mantenlo blanco para que contraste con el fondo.
  static const Color secondary = Color(0xFFFFFFFF);

  // Texto
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  // Fondos y bordes

  /// Color de fondo principal (Scaffold).
  /// CAMBIO RECOMENDADO: Usamos un gris azulado muy suave (Slate 100)
  /// en lugar del gris neutro. Combina perfecto con tu primary.
  static const Color background = Color(0xFFF1F5F9);

  /// Color utilizado para bordes.
  static const Color border = Color(0xFFE0E0E0);

  // Dark Mode Colors
  static const Color backgroundDark = Color(
    0xFF111827,
  ); // Un poco más azulado que el negro puro
  static const Color surfaceDark = Color(
    0xFF1F2937,
  ); // Gris azulado oscuro para tarjetas
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color borderDark = Color(0xFF374151);
  static const Color secondaryDark = Color(0xFF1F2937);

  // Estados
  static const Color success = Color(0xFF4CAF50);
  static const Color danger = Color(0xFFF44336);
  static const Color warning = Color(0xFFFFEB3B);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF0288D1);

  // Acciones
  static const Color edit = Color(0xFFFF9800);
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color hover = Color(0xFF1976D2);

  // Íconos
  static const Color iconPassive = Color(0xFF90CAF9);
}
