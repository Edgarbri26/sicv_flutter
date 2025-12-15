import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/config/app_permissions.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:sicv_flutter/config/app_routes.dart';
// Importa los NUEVOS providers
import 'package:sicv_flutter/providers/auth_provider.dart';
import 'package:sicv_flutter/providers/current_user_permissions_provider.dart';

class MySideBar extends ConsumerWidget {
  const MySideBar({super.key, required this.controller});

  final SidebarXController controller;

  // Colores (puedes dejarlos aquí o moverlos al tema global)
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Definimos colores desde el tema
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color sidebarBackgroundColor = Theme.of(context).cardColor;
    final Color textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87;
    final Color iconColor = Theme.of(context).iconTheme.color ?? Colors.grey;

    final authState = ref.watch(authProvider);
    final user = authState.value;
    final userPermissions = ref.watch(currentUserPermissionsProvider);

    final hasAccessMovements = userPermissions.can(
      AppPermissions.readMovements,
    );

    final hasAccessReports = userPermissions.can(AppPermissions.readReports);

    final hasAccessProducts = userPermissions.can(AppPermissions.readProducts);

    final hasAccessPurchases = userPermissions.can(
      AppPermissions.createPurchase,
    );

    final hasAccessSales = userPermissions.can(AppPermissions.createSale);
    return SidebarX(
      controller: controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: sidebarBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        textStyle: TextStyle(color: textColor, fontSize: 14),
        selectedTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: iconColor, size: 22),
        selectedIconTheme: const IconThemeData(color: Colors.white, size: 22),
        hoverColor: primaryColor.withValues(alpha: 0.1),
        hoverTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
        itemTextPadding: const EdgeInsets.only(left: 15),
        selectedItemTextPadding: const EdgeInsets.only(left: 15),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [
              primaryColor.withValues(alpha: 0.9),
              primaryColor.withValues(alpha: 0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        itemDecoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      ),
      extendedTheme: SidebarXTheme(
        width: 220,
        decoration: BoxDecoration(color: sidebarBackgroundColor),
      ),
      headerBuilder: (context, extended) {
        return SizedBox(
          height: extended ? 130 : 80,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(Icons.person, size: 40, color: iconColor),
                if (extended) ...[
                  const SizedBox(height: 4),
                  Text(
                    user?.name ?? "Usuario",
                    style: TextStyle(color: textColor),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    user?.role?.name ?? "Usuario",
                    style: TextStyle(
                      color: Theme.of(context).hintColor,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        );
      },
      items: [
        if (hasAccessSales)
          SidebarXItem(
            icon: Icons.point_of_sale,
            label: 'Ventas',
            onTap: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.sales),
          ),

        if (hasAccessPurchases)
          SidebarXItem(
            icon: Icons.shopping_cart,
            label: 'Compras',
            onTap: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.purchase),
          ),

        if (hasAccessProducts)
          SidebarXItem(
            icon: Icons.inventory,
            label: 'Inventario',
            onTap: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.inventory),
          ),

        if (hasAccessReports)
          SidebarXItem(
            icon: Icons.assessment,
            label: 'Reportes',
            onTap: () => Navigator.pushReplacementNamed(
              context,
              AppRoutes.reportDashboard,
            ),
          ),

        if (hasAccessMovements)
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
          onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
        ),
        SidebarXItem(
          icon: Icons.logout,
          label: 'Cerrar Sesión',
          onTap: () async {
            // 2. LOGOUT USANDO EL NUEVO AUTH PROVIDER
            await ref.read(authProvider.notifier).logout();

            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );
          },
        ),
      ],
    );
  }
}
