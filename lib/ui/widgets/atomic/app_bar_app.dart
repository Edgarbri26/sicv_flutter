import 'package:flutter/material.dart';
// Asegúrate de importar tu archivo de colores
import 'package:sicv_flutter/core/theme/app_colors.dart';

class AppBarApp extends StatelessWidget implements PreferredSizeWidget {
  /// El texto que se mostrará en el título.
  final String title;

  /// (Opcional) Una lista de widgets para mostrar a la derecha del título.
  final List<Widget>? actions;

  /// (Opcional) El widget para mostrar al inicio (izquierda).
  /// Si es nulo, Flutter pondrá automáticamente el botón de 'atrás' o 'menú'.
  final Widget? leading;

  /// (Opcional) La altura que tendrá el AppBar.
  final double toolbarHeight;

  /// Color de los iconos (por ejemplo el botón "back"). Si es nulo, usa AppColors.secondary.
  final Color? iconColor;

  const AppBarApp({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.toolbarHeight = 64.0,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // --- Estilos Fijos de tu Diseño ---
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,

      // --- Parámetros Dinámicos ---
      title: Text(
        title, // Usamos el parámetro 'title'
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: AppColors.textPrimary, // Mantenemos tu estilo
        ),
      ),
      toolbarHeight: toolbarHeight,
      actions:
          actions ??
          [const SizedBox(width: 16)], // Mantenemos tu 'action' por defecto
      leading: leading,

      // --- Estilos Fijos de tu Diseño ---
      iconTheme: IconThemeData(
        color:
            iconColor ??
            AppColors.textPrimary, // Permite override desde el widget
      ),
    );
  }

  /// Esto es requerido por `PreferredSizeWidget`
  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);
}
