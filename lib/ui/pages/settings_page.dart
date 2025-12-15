import 'package:flutter/material.dart';
import 'package:sicv_flutter/config/app_permissions.dart';
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';
import 'package:sicv_flutter/config/app_routes.dart';
import 'package:sicv_flutter/providers/current_user_permissions_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // bool _darkModeEnabled = true; // Removed local state
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final userPermissions = ref.watch(currentUserPermissionsProvider);
    // final themeMode = ref.watch(themeProvider);
    // final isDarkMode = themeMode == ThemeMode.dark;

    final hasAccessUserManagement = userPermissions.can(
      AppPermissions.manageUsers,
    );
    final hasAccessClientManagement = userPermissions.can(
      AppPermissions.manageClients,
    );
    final hasAccessProviderManagement = userPermissions.can(
      AppPermissions.manageProvider,
    );
    final hasAccessCategoryManagement = userPermissions.can(
      AppPermissions.manageCategories,
    );
    final hasAccessRoleManagement = userPermissions.can(
      AppPermissions.manageRoles,
    );
    final hasAccessDepotManagement = userPermissions.can(
      AppPermissions.manageDepots,
    );
    final hasAccessTypePaymentManagement = userPermissions.can(
      AppPermissions.managePaymentTypes,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBarApp(
        title: 'Configuración',
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        // Padding vertical general para el ListView
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          Center(
            // 1. Centra el bloque de contenido
            child: ConstrainedBox(
              // 2. Limita el ancho máximo del contenido
              constraints: const BoxConstraints(
                maxWidth: 700,
              ), // Ancho máximo deseado
              child: Padding(
                // 3. Padding horizontal DENTRO del área restringida
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  // 4. Importante: Estira los hijos para que ocupen el ancho restringido
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ⭐️⭐️⭐️ ¡TODO EL CONTENIDO VA AQUÍ DENTRO! ⭐️⭐️⭐️

                    // --- Sección del Avatar ---
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Icon(
                            Icons.person_outline_rounded,
                            size: 58,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Nombre de Usuario', // Reemplaza con el nombre real
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- Secciones de Configuración ---
                    _buildSectionTitle('CONFIGURACIÓN GENERAL'),

                    if (hasAccessTypePaymentManagement)
                      _buildConfigTile(
                        context: context,
                        title: 'Configuración de Los Tipos de Pago',
                        subtitle:
                            'Tipo de pago, Pago Movil, Transferencia, etc.',
                        icon: Icons.payment,
                        routeName: AppRoutes.typePayment,
                      ),
                    const SizedBox(height: 16),

                    if (hasAccessCategoryManagement || hasAccessDepotManagement)
                      _buildSectionTitle('CONFIGURACIÓN DE INVENTARIO'),

                    if (hasAccessCategoryManagement)
                      _buildConfigTile(
                        context: context,
                        title: 'Categorías y Subcategorías',
                        subtitle: 'Gestión de categorías',
                        icon: Icons.category,
                        routeName: AppRoutes.categories,
                      ),

                    if (hasAccessDepotManagement)
                      _buildConfigTile(
                        context: context,
                        title: 'Depositos y Almacenes',
                        subtitle: 'Gestión de depósitos',
                        icon: Icons.store,
                        routeName: AppRoutes.depot,
                      ),

                    const SizedBox(height: 16),
                    if (hasAccessRoleManagement ||
                        hasAccessUserManagement ||
                        hasAccessClientManagement ||
                        hasAccessProviderManagement)
                      _buildSectionTitle('CONFIGURACIÓN DE USUARIOS'),

                    if (hasAccessRoleManagement)
                      _buildConfigTile(
                        context: context,
                        title: 'Roles y Permisos',
                        subtitle: 'Administrador, Vendedor, Almacén',
                        icon: Icons.admin_panel_settings,
                        routeName: AppRoutes.roles,
                      ),

                    if (hasAccessUserManagement)
                      _buildConfigTile(
                        context: context,
                        title: 'Usuarios del Sistema',
                        subtitle: 'Agregar/editar/eliminar usuarios',
                        icon: Icons.account_circle,
                        routeName: AppRoutes.users,
                      ),

                    if (hasAccessClientManagement)
                      _buildConfigTile(
                        context: context,
                        title: 'Clientes del Sistema',
                        subtitle: 'Agregar/editar/eliminar clientes',
                        icon: Icons.people,
                        routeName: AppRoutes.client,
                      ),

                    if (hasAccessProviderManagement)
                      _buildConfigTile(
                        context: context,
                        title: 'Proveedores del Sistema',
                        subtitle: 'Agregar/editar/eliminar proveedores',
                        icon: Icons.local_shipping,
                        routeName: AppRoutes.provider,
                      ),

                    const SizedBox(height: 16),

                    // _buildSwitchTile(
                    //   title: 'Notificaciones',
                    //   value: _notificationsEnabled,
                    //   onChanged: (value) =>
                    //       setState(() => _notificationsEnabled = value),
                    //   icon: Icons.notifications,
                    // ),
                    _buildConfigTile(
                      context: context,
                      title: 'Interfaz y Tema',
                      subtitle: 'Modo claro/oscuro, idioma',
                      icon: Icons.palette,
                      routeName: AppRoutes.theme,
                    ),
                    const SizedBox(height: 30), // Padding final
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).textTheme.titleLarge?.color,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildConfigTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required String routeName,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).iconTheme.color),
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).iconTheme.color,
        ),
        onTap: () {
          Navigator.pushNamed(context, routeName);
        },
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).iconTheme.color),
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 16,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
