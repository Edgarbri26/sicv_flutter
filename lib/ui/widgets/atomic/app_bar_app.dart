import 'package:flutter/material.dart';
// Asegúrate de importar tu archivo de colores
import 'package:sicv_flutter/core/theme/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/providers/notificacion_provider.dart';

class AppBarApp extends ConsumerWidget implements PreferredSizeWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔔 Calculamos el número de notificaciones no leídas
    // Usamos watch sobre el provider (lista) directamente para reactividad
    final unreadCount = ref
        .watch(notificationProvider)
        .where((n) => !n.isRead)
        .length;

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
      actions: [
        // Insertamos las acciones previas si existen
        ...(actions ?? []),

        // 🔔 Botón de Notificaciones con Badge
        IconButton(
          onPressed: () {
            // TODO: Navegar a pantalla de notificaciones o abrir popup
            print("Abrir notificaciones");
          },
          icon: Badge(
            isLabelVisible: unreadCount > 0,
            label: Text('$unreadCount'),
            child: Icon(
              Icons.notifications_outlined,
              color: iconColor ?? AppColors.textPrimary,
            ),
          ),
        ),

        // Espaciado final
        const SizedBox(width: 16),
      ],
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
