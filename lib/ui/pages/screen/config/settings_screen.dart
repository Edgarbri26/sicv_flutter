import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/config/app_routes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkModeEnabled = true;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Configuración',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary,
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 58,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Nombre de Usuario',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('CONFIGURACIÓN GENERAL'),
          _buildConfigTile(
            context: context,
            title: 'Información de la Empresa',
            subtitle: 'Nombre, logo, dirección, datos fiscales',
            icon: Icons.business,
            routeName: AppRoutes.company,
          ),
          _buildConfigTile(
            context: context,
            title: 'Configuración de Moneda',
            subtitle: 'Tipo de moneda, decimales, símbolo',
            icon: Icons.attach_money,
            routeName: AppRoutes.currency,
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('CONFIGURACIÓN DE INVENTARIO'),
          _buildConfigTile(
            context: context,
            title: 'Unidades de Medida',
            subtitle: 'Pieza, kg, litro, etc.',
            icon: Icons.square_foot,
            routeName: AppRoutes.units,
          ),
          _buildConfigTile(
            context: context,
            title: 'Categorías y Subcategorías',
            subtitle: 'Gestión de categorías',
            icon: Icons.category,
            routeName: AppRoutes.categories,
          ),
          _buildConfigTile(
            context: context,
            title: 'Niveles de Stock',
            subtitle: 'Stock mínimo/máximo, alertas',
            icon: Icons.warning_amber,
            routeName: AppRoutes.stock,
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('CONFIGURACIÓN DE USUARIOS'),
          _buildConfigTile(
            context: context,
            title: 'Roles y Permisos',
            subtitle: 'Administrador, Vendedor, Almacén',
            icon: Icons.admin_panel_settings,
            routeName: AppRoutes.roles,
          ),
          _buildConfigTile(
            context: context,
            title: 'Usuarios del Sistema',
            subtitle: 'Agregar/editar/eliminar usuarios',
            icon: Icons.account_circle,
            routeName: AppRoutes.users,
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('CONFIGURACIÓN DE PRODUCTOS'),
          _buildConfigTile(
            context: context,
            title: 'Códigos y SKU',
            subtitle: 'Formato automático, prefijos',
            icon: Icons.qr_code,
            routeName: AppRoutes.sku,
          ),
          _buildConfigTile(
            context: context,
            title: 'Atributos de Productos',
            subtitle: 'Colores, tallas, modelos',
            icon: Icons.style,
            routeName: AppRoutes.atributes,
          ),
          const SizedBox(height: 16),
          /*
          _buildSectionTitle('REPORTES Y BACKUP'),
          _buildConfigTile(
            context: context,
            title: 'Configuración de Reportes',
            subtitle: 'Formatos de exportación (PDF, Excel)',
            icon: Icons.picture_as_pdf,
            routeName: AppRoutes.report,
          ),
          */
          _buildConfigTile(
            context: context,
            title: 'Backup Automático',
            subtitle: 'Frecuencia y destino de respaldos',
            icon: Icons.cloud_upload,
            routeName: AppRoutes.backup,
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('PREFERENCIAS DEL SISTEMA'),
          _buildSwitchTile(
            title: 'Modo Oscuro',
            value: _darkModeEnabled,
            onChanged: (value) => setState(() => _darkModeEnabled = value),
            icon: Icons.dark_mode,
          ),
          _buildSwitchTile(
            title: 'Notificaciones',
            value: _notificationsEnabled,
            onChanged: (value) => setState(() => _notificationsEnabled = value),
            icon: Icons.notifications,
          ),
          _buildConfigTile(
            context: context,
            title: 'Interfaz y Tema',
            subtitle: 'Modo claro/oscuro, idioma',
            icon: Icons.palette,
            routeName: AppRoutes.theme,
          ),
          const SizedBox(height: 30),
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
