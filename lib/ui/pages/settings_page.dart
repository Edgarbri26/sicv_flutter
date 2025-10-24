import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Configuración',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            // Puedes ajustar este valor. 600 es un buen
            // tamaño para formularios o listas de configuración.
            maxWidth: 600,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.hover,
                  child: Icon(Icons.person, size: 60, color: AppColors.background),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nombre de Usuario',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                // Todos los botones ahora tienen la misma separación
                _buildSettingsTile(
                  icon: Icons.edit,
                  title: 'Editar Perfil',
                  onTap: () {},
                ),
                _buildSettingsTile(
                  icon: Icons.dark_mode,
                  title: 'Modo Oscuro',
                  trailing: Switch(
                    value: _darkModeEnabled,
                    onChanged: (value) {
                      setState(() {
                        _darkModeEnabled = value;
                      });
                    },
                    activeThumbColor: AppColors.hover,
                  ),
                ),
                _buildSettingsTile(
                  icon: Icons.notifications,
                  title: 'Notificaciones',
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    activeThumbColor: AppColors.hover,
                  ),
                ),
                _buildSettingsTile(
                  icon: Icons.language,
                  title: 'Idioma',
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.secondary,
                    size: 18,
                  ),
                  onTap: () {},
                ),
                _buildSettingsTile(
                  icon: Icons.security,
                  title: 'Seguridad y Privacidad',
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.secondary,
                    size: 18,
                  ),
                  onTap: () {},
                ),
                _buildSettingsTile(
                  icon: Icons.help_outline,
                  title: 'Ayuda y Soporte',
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.secondary,
                    size: 18,
                  ),
                  onTap: () {},
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.hover),
        title: Text(
          title,
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
