import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/ui/pages/login_page.dart';
import 'package:sicv_flutter/ui/pages/movements_page.dart';
import 'package:sicv_flutter/ui/pages/report_dashboard_page.dart';
import 'package:sicv_flutter/ui/screen/config/settings_screen.dart';

class AppSidebar extends StatelessWidget {
  // Propiedades requeridas para la navegación de HomePage
  final int currentIndex;
  final Function(int) onItemSelected;

  // Propiedad para resaltar rutas que no sean del PageView (Reportes, Config)
  final String currentPageRoute;

  const AppSidebar({
    super.key,
    this.currentPageRoute = '',
    required this.currentIndex,
    required this.onItemSelected,
  });

  // Ítems de navegación principales (coinciden con el PageView de HomePage)
  final List<Map<String, dynamic>> _pageMenuItems = const [
    {'title': 'Venta', 'icon': Icons.point_of_sale, 'index': 0},
    {'title': 'Compra', 'icon': Icons.shopping_cart, 'index': 1},
    {'title': 'Inventario', 'icon': Icons.inventory, 'index': 2},
  ];

  @override
  Widget build(BuildContext context) {
    // Definición de datos de usuario simulados
    const String userName = "Usuario Real";
    const String userEmail = "usuario@ejemplo.com";
    final String userInitials =
        userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : '?';

    // 1. EL CAMBIO CLAVE: Usamos un Container en lugar de Drawer.
    // El tamaño (ancho) lo define el ConstrainedBox en HomePage.
    return Container(
      decoration: BoxDecoration(  
        color: Colors.white,  // Agrega un color para poder ver la forma
        borderRadius: BorderRadius.circular(20.0),
      ),
      width: double.infinity, // O AppColors.background si prefieres
      child: ClipRRect(
        borderRadius:  BorderRadius.only(topRight:Radius.circular(20)),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // Header de Usuario
            UserAccountsDrawerHeader(
              accountName: Text(
                userName,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white), // Asegura texto blanco
              ),
              accountEmail: Text(userEmail, style: TextStyle(color: Colors.white70)), // Asegura texto blanco
              currentAccountPicture: CircleAvatar(
                backgroundColor: AppColors.secondary,
                child: Text(
                  userInitials,
                  style: const TextStyle(
                    fontSize: 40.0,
                    color: AppColors.primary,
                  ),
                ),
              ),
              decoration: const BoxDecoration(color: AppColors.primary),
            ),
        
            // --- ÍTEMS DE NAVEGACIÓN (Venta, Compra, Inventario) ---
            ..._pageMenuItems.map((item) {
              final int itemIndex = item['index'] as int;
        
              return _buildMenuItem(
                context: context,
                icon: item['icon'] as IconData,
                title: item['title'] as String,
                isSelected:
                    itemIndex == currentIndex, // Resalta según el PageView
                onTap: () {
                  // Llama a la función de HomePage para cambiar de página
                  onItemSelected(itemIndex);
                },
                // No pasamos 'route' aquí, ya que la navegación es interna (PageView)
              );
            }),
        
            const Divider(thickness: 1),
        
            // --- ÍTEMS DE NAVEGACIÓN DE RUTAS (Reportes, Usuarios, Configuración) ---
        
            // Ítem: Reportes
            _buildMenuItem(
              context: context,
              icon: Icons.assessment_outlined,
              title: 'Reportes',
              route: '/reports', // Usamos la ruta para resaltar
              currentPageRoute: currentPageRoute,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportDashboardPage()),
                );
              },
            ),
        
            // Ítem: Administrar Usuarios
            /*_buildMenuItem(
              context: context,
              icon: Icons.group_outlined,
              title: 'Administrar usuarios',
              route: '/users',
              currentPageRoute: currentPageRoute,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => AdminUserManagementPage()),
                );
              },
            ),*/
        
            // Ítem: Administrar Movimientos
            _buildMenuItem(
              context: context,
              icon: Icons.compare_arrows,
              title: 'Administrar movimientos',
              route: '/movements', // Usa una ruta única
              currentPageRoute: currentPageRoute,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => MovementsPage()),
                );
              },
            ),
        
            const Divider(thickness: 1),
        
            // Ítem: Configuración
            _buildMenuItem(
              context: context,
              icon: Icons.settings_outlined,
              title: 'Configuración',
              route: '/settings',
              currentPageRoute: currentPageRoute,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
        
            // Ítem: Cerrar Sesión
            _buildMenuItem(
              context: context,
              icon: Icons.logout,
              title: 'Cerrar Sesión',
              onTap: () => _showLogoutConfirmation(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper para construir los ListTile del menú y manejar el estado 'selected'
  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String route = '',
    String currentPageRoute = '',
    bool isSelected = false, // Lo usamos para los ítems del PageView
  }) {
    // Si la ruta no es PageView, usamos la comparación de rutas para resaltar
    if (route.isNotEmpty) {
      isSelected = route == currentPageRoute;
    }

    // Identificamos si es móvil o PC
    // Usamos el mismo breakpoint de HomePage
    final bool isMobile = MediaQuery.of(context).size.width < 650.0;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).primaryColor : Colors.black54,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 16, // Tamaño de fuente más estándar para menú
        ),
      ),
      selected: isSelected,
      selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
      onTap: () {
        // --- LÓGICA CLAVE: Cierra el Drawer solo si es móvil ---
        if (isMobile) {
          // Si estamos en móvil, cerramos el drawer antes de navegar
          // Comprobamos si el drawer está abierto antes de hacer pop
          if (Scaffold.of(context).isDrawerOpen) {
            Navigator.pop(context);
          }
        }

        // Pequeña espera para una transición más suave (opcional)
        Future.delayed(const Duration(milliseconds: 150), onTap);
      },
    );
  }

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
}