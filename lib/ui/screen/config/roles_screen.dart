import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';

// --- 1. MODELOS DE DATOS (Simulación) ---

/// Define un permiso individual con su descripción
class Permission {
  final String key;
  final String name;
  final String description;

  Permission({
    required this.key,
    required this.name,
    required this.description,
  });
}

/// Define un grupo de permisos (ej. "Inventario")
class PermissionGroup {
  final String title;
  final List<Permission> permissions;

  PermissionGroup({required this.title, required this.permissions});
}

// --- 2. SIMULACIÓN DE BASE DE DATOS ---

/// TODOS los permisos disponibles en el sistema, agrupados por categoría.
final List<PermissionGroup> allPermissionGroups = [
  PermissionGroup(
    title: 'Gestión de Inventario',
    permissions: [
      Permission(
        key: 'inventory_read',
        name: 'Ver Inventario',
        description: 'Puede ver la lista de productos y stock actual.',
      ),
      Permission(
        key: 'inventory_create',
        name: 'Crear Productos',
        description: 'Puede añadir nuevos productos al sistema.',
      ),
      Permission(
        key: 'inventory_update',
        name: 'Editar Productos',
        description: 'Puede modificar precio, stock, descripción, etc.',
      ),
      Permission(
        key: 'inventory_delete',
        name: 'Eliminar Productos',
        description:
            'Permiso peligroso: puede borrar productos permanentemente.',
      ),
    ],
  ),
  PermissionGroup(
    title: 'Gestión de Ventas (POS)',
    permissions: [
      Permission(
        key: 'sales_create',
        name: 'Realizar Ventas',
        description:
            'Puede usar el punto de venta (POS) para registrar ventas.',
      ),
      Permission(
        key: 'sales_read',
        name: 'Ver Historial de Ventas',
        description: 'Puede ver la lista de ventas pasadas.',
      ),
      Permission(
        key: 'sales_cancel',
        name: 'Anular Ventas',
        description: 'Puede cancelar o reembolsar una venta ya registrada.',
      ),
    ],
  ),
  PermissionGroup(
    title: 'Gestión de Compras',
    permissions: [
      Permission(
        key: 'purchases_create',
        name: 'Registrar Compras',
        description:
            'Puede registrar la entrada de mercancía (compras a proveedores).',
      ),
      Permission(
        key: 'purchases_read',
        name: 'Ver Historial de Compras',
        description: 'Puede ver la lista de compras pasadas.',
      ),
    ],
  ),
  PermissionGroup(
    title: 'Reportes y Analíticas',
    permissions: [
      Permission(
        key: 'reports_read',
        name: 'Ver Reportes',
        description:
            'Puede acceder a los reportes de ventas, ganancias e inventario.',
      ),
    ],
  ),
  PermissionGroup(
    title: 'Administración del Sistema',
    permissions: [
      Permission(
        key: 'users_manage',
        name: 'Gestionar Usuarios',
        description: 'Puede crear, editar o eliminar otros usuarios.',
      ),
      Permission(
        key: 'roles_manage',
        name: 'Gestionar Roles',
        description: 'Puede editar los permisos de todos los roles.',
      ),
    ],
  ),
];

/// Simulación de los permisos asignados a cada rol en la BD.
/// Usamos un Set<String> para una búsqueda rápida (contiene la 'key' del permiso).
final Map<String, Set<String>> mockRolePermissionsData = {
  'Administrador': {
    // Todos los permisos
    'inventory_read',
    'inventory_create',
    'inventory_update',
    'inventory_delete',
    'sales_create', 'sales_read', 'sales_cancel',
    'purchases_create', 'purchases_read',
    'reports_read',
    'users_manage', 'roles_manage',
  },
  'Vendedor': {
    // Solo permisos de venta e inventario (lectura)
    'inventory_read',
    'sales_create', 'sales_read',
  },
  'Almacén': {
    // Solo permisos de inventario y compras
    'inventory_read', 'inventory_create', 'inventory_update',
    'purchases_create', 'purchases_read',
  },
};

// --- 3. VISTA PRINCIPAL (WIDGET) ---

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

  String? _selectedRoleName;

  // Mapa para guardar los permisos del rol seleccionado (el estado de los checkboxes)
  Map<String, bool> _currentPermissions = {};

  @override
  void initState() {
    super.initState();
    // Opcional: Seleccionar el primer rol por defecto
    // _selectRole(_roles.first['nombre']);
  }

  /// Carga los permisos para un rol seleccionado
  void _selectRole(String roleName) {
    setState(() {
      _selectedRoleName = roleName;

      // Simula la carga desde la "base de datos"
      final Set<String> permissionsForRole =
          mockRolePermissionsData[roleName] ?? {};

      // Resetea el mapa de permisos actual
      _currentPermissions = {};

      // Llena el mapa de permisos basado en TODOS los permisos disponibles
      for (var group in allPermissionGroups) {
        for (var perm in group.permissions) {
          // Si el rol tiene este permiso en la "BD", márcalo como true
          _currentPermissions[perm.key] = permissionsForRole.contains(perm.key);
        }
      }
    });
  }

  /// Actualiza un permiso en el estado local (cuando se toca un checkbox)
  void _updatePermission(String key, bool? value) {
    setState(() {
      _currentPermissions[key] = value ?? false;
    });
  }

  /// Simula el guardado de permisos en la base de datos
  void _savePermissions() {
    if (_selectedRoleName == null) return;

    // EN UN CASO REAL: Aquí llamas a tu API/Servicio
    // "GuardarPermisosParaRol(_selectedRoleName, _currentPermissions)"

    print('Guardando permisos para $_selectedRoleName:');
    print(
      _currentPermissions.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList(),
    );

    // Actualiza la "BD" simulada
    mockRolePermissionsData[_selectedRoleName!] = _currentPermissions.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toSet();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Permisos de $_selectedRoleName guardados.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // --- CONSTRUCCIÓN DE LA UI ---

  @override
  Widget build(BuildContext context) {
    // Punto de corte: si es menor de 650px, es 'móvil'
    const double breakpoint = 650.0;

    return Scaffold(
      appBar: AppBarApp(
        title: 'Roles y Permisos',
        iconColor: AppColors.textPrimary,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth >= breakpoint;

          if (isWide) {
            // VISTA PC: Panel dividido
            return Row(
              children: [
                // Panel Maestro (Lista de Roles)
                SizedBox(
                  width: 280,
                  // Usamos un fondo sutil para diferenciar el panel
                  child: Material(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    child: _buildRoleList(context),
                  ),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                // Panel Detalle (Permisos)
                Expanded(child: _buildPermissionPane(context)),
              ],
            );
          } else {
            // VISTA MÓVIL: Muestra un panel o el otro
            if (_selectedRoleName == null) {
              // Muestra la lista de roles
              return _buildRoleList(context);
            } else {
              // Muestra los permisos del rol seleccionado
              return _buildPermissionPane(context);
            }
          }
        },
      ),
    );
  }

  /// Construye el botón de 'Atrás' del AppBar (solo para móvil)
  Widget? _buildAppBarLeading(BuildContext context, double breakpoint) {
    final bool isNarrow = MediaQuery.of(context).size.width < breakpoint;
    // Solo muestra el botón 'Atrás' si estamos en móvil Y un rol está seleccionado
    if (isNarrow && _selectedRoleName != null) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          // Al presionar 'Atrás', volvemos a la lista de roles
          setState(() {
            _selectedRoleName = null;
          });
        },
      );
    }
    // Si no, Flutter usará el botón 'Atrás' o 'Menú' por defecto
    return null;
  }

  /// Panel Maestro: La lista de roles
  Widget _buildRoleList(BuildContext context) {
    return ListView.builder(
      itemCount: _roles.length,
      itemBuilder: (context, index) {
        final rol = _roles[index];
        final bool isSelected = _selectedRoleName == rol['nombre'];

        return ListTile(
          leading: Icon(rol['icon']),
          title: Text(rol['nombre']),
          selected: isSelected, // Resalta el rol seleccionado
          selectedTileColor: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.1),
          onTap: () => _selectRole(rol['nombre']),
        );
      },
    );
  }

  /// Panel Detalle: Los permisos y el botón de guardar
  Widget _buildPermissionPane(BuildContext context) {
    final theme = Theme.of(context);

    // Si no hay rol seleccionado, muestra un placeholder
    if (_selectedRoleName == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Seleccione un rol de la lista para gestionar sus permisos.',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Si hay un rol, construye la vista de permisos
    return Column(
      children: [
        // La lista de permisos (ocupa todo el espacio menos el botón)
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16.0),
            // Iteramos sobre los GRUPOS de permisos
            itemCount: allPermissionGroups.length,
            separatorBuilder: (context, index) => const Divider(height: 32),
            itemBuilder: (context, index) {
              final group = allPermissionGroups[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título de la sección (ej. "Gestión de Inventario")
                  Text(
                    group.title.toUpperCase(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Lista de Checkboxes para este grupo
                  ...group.permissions.map((perm) {
                    return _buildPermissionTile(
                      perm,
                      _currentPermissions[perm.key] ?? false,
                    );
                  }),
                ],
              );
            },
          ),
        ),

        // El botón de Guardar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          child: FilledButton.icon(
            icon: const Icon(Icons.save),
            label: Text('Guardar Permisos para $_selectedRoleName'),
            onPressed: _savePermissions,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  /// Helper para construir cada fila de permiso (CheckboxListTile)
  Widget _buildPermissionTile(Permission perm, bool hasPermission) {
    return CheckboxListTile(
      value: hasPermission,
      title: Text(
        perm.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        perm.description,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onChanged: (bool? newValue) {
        _updatePermission(perm.key, newValue);
      },
      controlAffinity:
          ListTileControlAffinity.leading, // Checkbox a la izquierda
      contentPadding: EdgeInsets.zero,
    );
  }
}
