import 'package:flutter/material.dart';

class RolesScreen extends StatefulWidget {
  const RolesScreen({super.key});

  @override
  _RolesScreenState createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  final List<Map<String, dynamic>> _roles = [
    {'nombre': 'Administrador', 'icon': Icons.admin_panel_settings},
    {'nombre': 'Vendedor', 'icon': Icons.person},
    {'nombre': 'Almacén', 'icon': Icons.inventory},
  ];

  void _gestionarPermisos(String rol) {
    print('TODO: Gestionar permisos para $rol');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Abriendo configuración para $rol...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Roles y Permisos',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _roles.length,
        itemBuilder: (context, index) {
          final rol = _roles[index];
          return ListTile(
            leading: Icon(rol['icon'] as IconData),
            title: Text(rol['nombre'] as String),
            subtitle: const Text('Tocar para editar permisos'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _gestionarPermisos(rol['nombre'] as String),
          );
        },
      ),
    );
  }
}
