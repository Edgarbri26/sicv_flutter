import 'package:flutter/material.dart';
import 'package:sicv_flutter/config/app_routes.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/providers/role_provider.dart';
import 'package:sicv_flutter/providers/user_permissions_provider.dart';
import 'package:sicv_flutter/providers/user_provider.dart';
import 'package:sidebarx/sidebarx.dart';

class MySideBar extends ConsumerWidget {
  const MySideBar({super.key, required this.controller});

  final SidebarXController controller;
  final Color primaryColor = AppColors.primary;
  // Color de fondo de la barra lateral, usando el color de fondo de la aplicación
  final Color sidebarBackgroundColor = AppColors.background;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPermissions = ref.watch(userPermissionsProvider);
    final hasAccessMoviments = userPermissions.contains('all:permissions');

    print("🧐 PERMISOS EN MEMORIA: $userPermissions");

    return SidebarX(
      controller: controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: sidebarBackgroundColor,
          // Borde redondeado suave para el contenedor principal de la barra
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        // Estilos de Texto e Iconos
        textStyle: TextStyle(color: AppColors.textPrimary, fontSize: 14),
        selectedTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        iconTheme: IconThemeData(color: AppColors.textSecondary, size: 22),
        selectedIconTheme: const IconThemeData(color: Colors.white, size: 22),

        // Estilo al pasar el ratón (Hover)
        hoverColor: primaryColor.withOpacity(0.1),
        hoverTextStyle: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.w600,
        ),

        itemTextPadding: const EdgeInsets.only(left: 15),
        selectedItemTextPadding: const EdgeInsets.only(left: 15),

        // --- DECORACIÓN DEL ELEMENTO SELECCIONADO (GRADIENTE) ---
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          // Replicamos el gradiente sutil de la vista de ventas
          gradient: LinearGradient(
            colors: [
              primaryColor.withOpacity(0.9), // Color primario fuerte
              primaryColor.withOpacity(0.6), // Color primario más suave
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),

        // Estilo de los elementos no seleccionados
        itemDecoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      ),

      // --- TEMA EXTENDIDO ---
      extendedTheme: SidebarXTheme(
        width: 220, // Un poco más ancho para desktop
        decoration: BoxDecoration(color: sidebarBackgroundColor),
      ),
      headerBuilder: (context, extended) {
        return SizedBox(
          height: 100,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Icon(Icons.person),
            // child: Image.asset('assets/images/avatar.png'),
          ),
        );
      },
      items: [
        SidebarXItem(
          icon: Icons.home,
          label: 'Inicio',
          onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
        ),
        SidebarXItem(
          icon: Icons.point_of_sale,
          label: 'Ventas',
          onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.sales),
        ),
        SidebarXItem(
          icon: Icons.shopping_cart,
          label: 'Compras',
          onTap: () =>
              Navigator.pushReplacementNamed(context, AppRoutes.purchase),
        ),

        SidebarXItem(
          icon: Icons.inventory,
          label: 'Inventario',
          onTap: () =>
              Navigator.pushReplacementNamed(context, AppRoutes.inventory),
        ),
        SidebarXItem(
          icon: Icons.assessment,
          label: 'Reportes',
          onTap: () => Navigator.pushReplacementNamed(
            context,
            AppRoutes.reportDashboard,
          ),
          selectable: false,
        ),

        if (hasAccessMoviments)
          SidebarXItem(
            icon: Icons.compare_arrows,
            label: 'Movimientos',
            onTap: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.movements),
          ),
      ],

      footerItems: [
        SidebarXItem(
          icon: Icons.settings,
          label: 'Configuración',
          onTap: () {
            Navigator.pushReplacementNamed(context, AppRoutes.settings);
          },
        ),

        SidebarXItem(
          icon: Icons.logout,
          label: 'Cerrar Sesión',
          onTap: () async {
            // No alteramos el índice del controller aquí: dejamos el estado
            // del Sidebar tal cual. Solo realizamos el logout y la navegación.
            final success = await ref.read(userProvider.notifier).logout();
            if (success) {
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            } else {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error al cerrar sesión')),
              );
            }
          },
        ),
      ],
    );
  }
}
