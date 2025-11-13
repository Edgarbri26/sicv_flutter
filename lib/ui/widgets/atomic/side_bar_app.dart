import 'package:flutter/material.dart';
import 'package:sicv_flutter/config/app_routes.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/models/icon_menu.dart';
import 'package:sicv_flutter/ui/pages/login_page.dart';
import 'package:sicv_flutter/ui/widgets/menu_item.dart';

class SideBarApp extends StatefulWidget {
  const SideBarApp({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
    required this.pageMenuItems,
    required this.currentPageRoute,
  });
  final int currentIndex;
  final Function(int) onItemSelected;
  final List<IconMenu> pageMenuItems;
  // Propiedad para resaltar rutas que no sean del PageView (Reportes, Config)
  final String currentPageRoute;

  @override
  _SideBarAppState createState() => _SideBarAppState();
}

class _SideBarAppState extends State<SideBarApp> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Definición de datos de usuario simulados
    /*const String userName = "Usuario Real";
    const String userEmail = "usuario@ejemplo.com";
    final String userInitials = userName.isNotEmpty
        ? userName.substring(0, 1).toUpperCase()
        : '?';*/

    // 1. EL CAMBIO CLAVE: Usamos un Container en lugar de Drawer.
    // El tamaño (ancho) lo define el ConstrainedBox en HomePage.
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background, // Agrega un color para poder ver la forma
        // borderRadius: BorderRadius.circular(20.0),
      ),
      // <-- CORRECCIÓN 1: Usamos un ancho fijo en lugar de double.infinity
      width: _isExpanded ? 250.0 : 100.0,
      child: Column(
        children: <Widget>[
          // Header de Usuario
          // Container(
          //   // padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingXS),
          //   height: 100,
          //   width: double.infinity,
          //   decoration: BoxDecoration(
          //     color: _isExpanded ? AppColors.primary : AppColors.background,
          //   ),
          //   child: Center(
          //     // <-- CORRECCIÓN 2: Layout del Row ajustado
          //     child: Row(
          //       // spacing: AppSizes.spacingXS,
          //       // Centra el icono cuando está colapsado
          //       mainAxisAlignment: _isExpanded
          //           ? MainAxisAlignment.start
          //           : MainAxisAlignment.center,
          //       crossAxisAlignment: CrossAxisAlignment.center,
          //       // spacing: 10, // <-- ESTE ERA EL ERROR, SE ELIMINA
          //       children: [
          //         // Padding izquierdo solo si está expandido
          //         // if (_isExpanded) const SizedBox(width: 10),
          //         CircleAvatar(
          //           radius: _isExpanded ? 30 : 16,
          //           backgroundColor: !_isExpanded
          //               ? AppColors.primary
          //               : AppColors.background,
          //           child: Text(
          //             userInitials,
          //             style: TextStyle(
          //               fontSize: _isExpanded ? 40.0 : 16.0,
          //               color: !_isExpanded
          //                   ? AppColors.background
          //                   : AppColors.primary,
          //             ),
          //           ),
          //         ),

          //         if (_isExpanded)
          //           // Usamos Expanded para que el texto no se desborde
          //           Expanded(
          //             child: Column(
          //               mainAxisAlignment: MainAxisAlignment.center,
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 Text(userName, overflow: TextOverflow.ellipsis),
          //                 Text(userEmail, overflow: TextOverflow.ellipsis),
          //               ],
          //             ),
          //           ),
          //       ],
          //     ),
          //   ),
          // ),

          // ... (El UserAccountsDrawerHeader comentado se queda igual) ...

          // --- ÍTEMS DE NAVEGACIÓN (Venta, Compra, Inventario) ---
          ...widget.pageMenuItems.map((item) {
            final int itemIndex = item.index;

            return MenuItem(
              isExpanded: _isExpanded,
              context: context,
              icon: item.icon,
              title: _isExpanded ? item.label : null,
              isSelected:
                  itemIndex == widget.currentIndex, // Resalta según el PageView
              onTap: () {
                // Llama a la función de HomePage para cambiar de página
                widget.onItemSelected(itemIndex);
              },
              // No pasamos 'route' aquí, ya que la navegación es interna (PageView)
            );
          }),
          const Divider(thickness: 1),

          // --- ÍTEMS DE NAVEGACIÓN DE RUTAS (Reportes, Usuarios, Configuración) ---

          // Ítem: Reportes
          MenuItem(
            isExpanded: _isExpanded,
            isSelected: false,
            context: context,
            icon: Icons.assessment_outlined,
            title: _isExpanded ? 'Reportes' : null,
            route: '/reports', // Usamos la ruta para resaltar
            currentPageRoute: widget.currentPageRoute,
            onTap: () {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.reportDashboard,
              );
            },
          ),

          // ... (El ítem de 'Administrar Usuarios' comentado se queda igual) ...

          // Ítem: Administrar Movimientos
          MenuItem(
            isExpanded: _isExpanded,
            isSelected: false,
            context: context,
            icon: Icons.compare_arrows,
            title: _isExpanded ? 'Administrar movimientos' : null,
            route: '/movements', // Usa una ruta única
            currentPageRoute: widget.currentPageRoute,
            onTap: () {
              // Navigator.pushReplacement(
              //   context,
              //   // MaterialPageRoute(builder: (_) => MovementsPage()),
              // );
            },
          ),

          const Divider(thickness: 1),

          // Ítem: Configuración
          MenuItem(
            isExpanded: _isExpanded,
            isSelected: false,
            context: context,
            icon: Icons.settings_outlined,
            title: _isExpanded ? 'Configuración' : null,
            route: '/settings',
            currentPageRoute: widget.currentPageRoute,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),

          // Ítem: Cerrar Sesión
          MenuItem(
            isExpanded: _isExpanded,
            isSelected: false,
            context: context,
            icon: Icons.logout,
            title: _isExpanded ? 'Cerrar Sesión' : null,
            onTap: () => _showLogoutConfirmation(context),
          ),
          const Divider(thickness: 1),

          // <-- CORRECCIÓN 3: Botón para expandir/colapsar
          // Usamos Spacer para empujar el botón al fondo
          const Spacer(),

          // Ítem: Expandir/Colapsar
          MenuItem(
            isExpanded: _isExpanded,
            isSelected: false,
            context: context,
            icon: _isExpanded
                ? Icons.arrow_back_ios_new
                : Icons.arrow_forward_ios,
            title: _isExpanded ? 'Colapsar' : null,
            onTap: _expandirMenu, // Llama a la función
          ),
          const SizedBox(height: 10), // Un pequeño padding inferior
        ],
      ),
    );
  }

  /// Helper para construir los ListTile del menú y manejar el estado 'selected'
  /// Helper para construir los ListTile del menú y manejar el estado 'selected'

  // (Mantenemos tu función _showLogoutConfirmation)
  void _showLogoutConfirmation(BuildContext context) {
    // ... (Tu código de _showLogoutConfirmation) ...
    // ...
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Cierre de Sesión'),
          content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red[700]),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Si el drawer sigue abierto (solo posible en móvil), lo cerramos
                if (Navigator.of(context).canPop()) {
                  Navigator.pop(context);
                }

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _expandirMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }
}
