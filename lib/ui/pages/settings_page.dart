import 'package:flutter/material.dart';
import 'package:sicv_flutter/config/app_permissions.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBarApp(
        title: 'Configuración',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
                          backgroundColor: AppColors.primary,
                          child: const Icon(
                            Icons.person_outline_rounded,
                            size: 58,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Nombre de Usuario', // Reemplaza con el nombre real
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- Secciones de Configuración ---
                    _buildSectionTitle('CONFIGURACIÓN GENERAL'),
                    /*_buildConfigTile(
                      context: context,
                      title: 'Indicaciones de tu perfil',
                      subtitle: 'Nombre, contraseña, foto',
                      icon: Icons.person,
                      routeName: AppRoutes.perfil,
                    ),*/

                    /*_buildConfigTile(
                      context: context,
                      title: 'Configuración de Moneda',
                      subtitle: 'Tipo de moneda, decimales, símbolo',
                      icon: Icons.attach_money,
                      routeName: AppRoutes.currency,
                    ),*/
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

                    /*_buildConfigTile(
                      context: context,
                      title: 'Unidades de Medida',
                      subtitle: 'Pieza, kg, litro, etc.',
                      icon: Icons.square_foot,
                      routeName: AppRoutes.units,
                    ),*/
                    if (hasAccessCategoryManagement)
                      _buildConfigTile(
                        context: context,
                        title: 'Categorías y Subcategorías',
                        subtitle: 'Gestión de categorías',
                        icon: Icons.category,
                        routeName: AppRoutes.categories,
                      ),

                    /*_buildConfigTile(
                      context: context,
                      title: 'Niveles de Stock',
                      subtitle: 'Stock mínimo/máximo, alertas',
                      icon: Icons.warning_amber,
                      routeName: AppRoutes.stock,
                    ),*/
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
                    /*_buildSectionTitle('CONFIGURACIÓN DE PRODUCTOS'),*/

                    /*_buildConfigTile(
                      context: context,
                      title: 'Códigos y SKU',
                      subtitle: 'Formato automático, prefijos',
                      icon: Icons.qr_code,
                      routeName: AppRoutes.sku,
                    ),*/
                    /*_buildConfigTile(
                      context: context,
                      title: 'Atributos de Productos',
                      subtitle: 'Colores, tallas, modelos',
                      icon: Icons.style,
                      routeName: AppRoutes.atributes,
                    ),*/
                    /*const SizedBox(height: 16),
                    _buildSectionTitle('REPORTES Y BACKUP'),
                    _buildConfigTile(
                      context: context,
                      title: 'Configuración de Reportes',
                      subtitle: 'Formatos de exportación (PDF, Excel)',
                      icon: Icons.picture_as_pdf,
                      routeName: AppRoutes.reportDashboard,
                    ),*/
                    /*_buildConfigTile(
                      context: context,
                      title: 'Backup Automático',
                      subtitle: 'Frecuencia y destino de respaldos',
                      icon: Icons.cloud_upload,
                      routeName: AppRoutes.backup,
                    ),*/
                    // const SizedBox(height: 16),
                    // _buildSectionTitle('PREFERENCIAS DEL SISTEMA'),
                    // _buildSwitchTile(
                    //   title: 'Modo Oscuro',
                    //   value: isDarkMode,
                    //   onChanged: (value) {
                    //     // ref.read(themeProvider.notifier).toggleTheme(value);
                    //     // setState(() => isDarkMode = value);
                    //   },
                    //   icon: Icons.dark_mode,
                    // ),
                    _buildSwitchTile(
                      title: 'Notificaciones',
                      value: _notificationsEnabled,
                      onChanged: (value) =>
                          setState(() => _notificationsEnabled = value),
                      icon: Icons.notifications,
                    ),
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
        style: const TextStyle(
          color: Colors.black,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(
          title,
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.black),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(
          title,
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
        ),
      ),
    );
  }
}
