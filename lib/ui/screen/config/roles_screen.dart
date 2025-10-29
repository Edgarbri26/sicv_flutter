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
    // Aquí navegarías a la pantalla de permisos para ese rol
  }

  @override
  Widget build(BuildContext context) {
    // Usamos los colores y temas de la app para consistencia
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Roles y Permisos')),
      // 1. Añadimos Padding para que la cuadrícula "respire"
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // 2. Cambiamos ListView por GridView.builder
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            // 3. Define el tamaño máximo de cada "tarjeta"
            // Flutter calculará cuántas columnas caben
            maxCrossAxisExtent: 250.0,
            // 4. Espaciado entre tarjetas
            mainAxisSpacing: 16.0,
            crossAxisSpacing: 16.0,
            // 5. Relación de aspecto (un poco más anchas que altas)
            childAspectRatio: 1.2,
          ),
          itemCount: _roles.length,
          itemBuilder: (context, index) {
            final rol = _roles[index];
            
            // 6. Usamos Card para un look moderno con elevación
            return Card(
              // 7. 'clipBehavior' es clave para que el 'InkWell' respete los bordes
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 4.0,
              // 8. Usamos InkWell para el efecto "splash" (onda) al tocar
              child: InkWell(
                onTap: () => _gestionarPermisos(rol['nombre']),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  // 9. Centramos el contenido de la tarjeta
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 10. Un icono más grande y con color
                      Icon(
                        rol['icon'],
                        size: 48.0,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 12.0),
                      // 11. Texto del rol con mejor estilo
                      Text(
                        rol['nombre'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Gestionar permisos',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}