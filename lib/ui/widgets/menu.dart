import 'package:flutter/material.dart';
import 'package:sicv_flutter/config/app_routes.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart'; // Mantienes tus colores
import 'package:sicv_flutter/core/theme/app_sizes.dart';
import 'package:sicv_flutter/core/theme/app_text_styles.dart';
import 'package:sicv_flutter/ui/pages/login_page.dart';

// Asume que tienes una página de perfil
// import 'package/sicv_flutter/ui/pages/profile_page.dart';

class Menu extends StatelessWidget {
  // --- MEJORA: Recibe la ruta actual para resaltar ---
  final String currentPageRoute; // Ejemplo: '/home', '/reports', '/users'

  const Menu({
    super.key,
    this.currentPageRoute = '', // Valor por defecto si no se pasa
  });

  @override
  Widget build(BuildContext context) {
    // --- MEJORA: Simula datos del usuario (deberías obtenerlos del estado global) ---
    const String userName = "Usuario Real"; // Reemplaza con datos reales
    const String userEmail =
        "usuario@ejemplo.com"; // Reemplaza con datos reales
    final String userInitials = userName.isNotEmpty
        ? userName.substring(0, 1).toUpperCase()
        : '?';

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        // --- MEJORA: Usa UserAccountsDrawerHeader ---
        UserAccountsDrawerHeader(
          accountName: Text(
            userName,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.secondary),
          ),
          accountEmail: Text(
            userEmail,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondary,
            ),
          ),
          currentAccountPicture: CircleAvatar(
            backgroundColor: AppColors.secondary, // O usa una imagen
            child: Text(
              userInitials,
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          decoration: BoxDecoration(
            color: AppColors.primary, // Usa tu color primario
          ),
          // Puedes añadir otros avatares aquí si quieres
          // otherAccountsPictures: <Widget>[ ... ],
        ),

        // --- MEJORA: Usa _buildMenuItem helper ---
        _buildMenuItem(
          context: context,
          icon: Icons.person_outline, // Icono de perfil
          title: 'Perfil',
          route: '/profile', // Asume que tienes una ruta para perfil
          currentPageRoute: currentPageRoute,
          onTap: () {
            // Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage()));
            // O mejor con rutas nombradas:
            //Navigator.pushReplacementNamed(context, '/profile');
          },
        ),
        _buildMenuItem(
          context: context,
          icon: Icons.home, // Icono de reportes
          title: 'Inicio',
          route: '/home',
          currentPageRoute: currentPageRoute,
          onTap: () {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
            // O mejor con rutas nombradas:
            // Navigator.pushReplacementNamed(context, '/reports');
          },
        ),
        _buildMenuItem(
          context: context,
          icon: Icons.assessment_outlined, // Icono de reportes
          title: 'Reportes',
          route: '/reports',
          currentPageRoute: currentPageRoute,
          onTap: () {
            Navigator.pushReplacementNamed(context, AppRoutes.reportDashboard);
          },
        ),
        /*_buildMenuItem(
          context: context,
          icon: Icons.group_outlined, // Icono de usuarios
          title: 'Administrar usuarios',
          route: '/users',
          currentPageRoute: currentPageRoute,
          onTap: () {
            Navigator.pushReplacementNamed(context, AppRoutes.users);
            // O mejor con rutas nombradas:
            // Navigator.pushReplacementNamed(context, '/users');
          },
        ),*/
        _buildMenuItem(
          context: context,
          icon: Icons.compare_arrows, // Icono de usuarios
          title: 'Administrar movimientos',
          route: '/users',
          currentPageRoute: currentPageRoute,
          onTap: () {
            Navigator.pushReplacementNamed(context, AppRoutes.movements);
          },
        ),

        // --- MEJORA: Separador antes de configuración y logout ---
        const Divider(thickness: 1),

        _buildMenuItem(
          context: context,
          icon: Icons.settings_outlined, // Icono de configuración
          title: 'Configuración',
          route: '/settings',
          currentPageRoute: currentPageRoute,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.settings);
          },
        ),

        // --- MEJORA: Logout al final con confirmación ---
        _buildMenuItem(
          context: context,
          icon: Icons.logout, // Icono de logout
          title: 'Cerrar Sesión',
          onTap: () => _showLogoutConfirmation(context), // Llama al diálogo
        ),
      ],
    );
  }

  /// Helper para construir los ListTile del menú y manejar el estado 'selected'
  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String route = '', // Ruta asociada a este item
    String currentPageRoute = '', // Ruta actual de la app
  }) {
    // Determina si este item es el seleccionado
    final bool isSelected = route.isNotEmpty && route == currentPageRoute;

    return ListTile(
      leading: Icon(
        icon,
        // --- MEJORA: Usa colores del tema o resalta si está seleccionado ---
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: AppSizes.bodyM,
        ),
      ),
      // --- MEJORA: Efecto visual al seleccionar ---
      selected: isSelected,
      // ignore: deprecated_member_use
      selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
      onTap: () {
        Navigator.pop(context); // Cierra el drawer ANTES de navegar
        // Pequeña espera para que el drawer se cierre suavemente (opcional)
        // Future.delayed(const Duration(milliseconds: 150), onTap);
      },
    );
  }

  /// Muestra un diálogo de confirmación antes de cerrar sesión
  void _showLogoutConfirmation(BuildContext context) {
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
                Navigator.of(dialogContext).pop(); // Cierra el diálogo
              },
            ),
            TextButton(
              child: Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red[700]),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Cierra el diálogo
                Navigator.pop(context); // Cierra el drawer si sigue abierto

                // --- MEJORA: Usa pushAndRemoveUntil para limpiar la pila de navegación ---
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (Route<dynamic> route) =>
                      false, // Elimina todas las rutas anteriores
                );
                // Aquí también deberías limpiar el estado de autenticación (tokens, etc.)
              },
            ),
          ],
        );
      },
    );
  }
}
