import 'package:flutter/material.dart';

/// {@template app_colors}
/// AppColors centraliza la paleta de colores utilizada en la aplicación.
///
/// Esta clase proporciona constantes para los colores principales, secundarios,
/// de texto, fondos, bordes, estados, acciones e íconos. Sirve para mantener
/// la consistencia visual en toda la interfaz y facilita la actualización de
/// la identidad visual desde un solo punto.
///
/// Todos los colores están definidos como constantes estáticas, y la clase
/// no puede ser instanciada.
///
/// Ejemplo de uso:
/// ```dart
/// Container(
///   color: AppColors.primary,
///   child: Text(
///     'Título',
///     style: TextStyle(color: AppColors.textPrimary),
///   ),
/// )
/// ```
/// {@endtemplate}
class AppColors {
  AppColors._();

  /// Color principal de la aplicación.
  static const Color primary = Color.fromARGB(255, 45, 63, 87);

  /// Color secundario, típico para fondos o elementos neutrales.
  static const Color secondary = Color(0xFFFFFFFF);

  // Texto

  /// Color principal para textos.
  static const Color textPrimary = Color(0xFF212121);

  /// Color secundario para textos.
  static const Color textSecondary = Color(0xFF757575);

  // Fondos y bordes

  /// Color de fondo principal.
  static const Color background = Color(0xFFF5F5F5);

  /// Color utilizado para bordes.
  static const Color border = Color(0xFFE0E0E0);

  // Dark Mode Colors
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color borderDark = Color(0xFF333333);
  static const Color secondaryDark = Color(
    0xFF2C2C2C,
  ); // For cards/inputs in dark mode

  // Estados

  /// Color utilizado para estados exitosos (ej. compras).
  static const Color success = Color(0xFF4CAF50);

  /// Color utilizado para advertencias críticas o ventas.
  static const Color danger = Color(0xFFF44336);

  /// Color utilizado para advertencias leves.
  static const Color warning = Color(0xFFFFEB3B);

  /// Color utilizado para errores.
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF0288D1);

  // Acciones

  /// Color utilizado para acciones de edición.
  static const Color edit = Color(0xFFFF9800);

  /// Color para estados deshabilitados.
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color hover = Color(0xFF1976D2);

  // Íconos

  /// Color para íconos en estado pasivo/inactivo.
  static const Color iconPassive = Color(0xFF90CAF9);
}
