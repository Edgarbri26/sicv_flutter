// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:flutter/material.dart';

/*
 * =============================================================================
 * PÁGINA DE GESTIÓN DE USUARIOS (SOLO ADMIN)
 * =============================================================================
 * * 1. Propósito:
 * - Esta página muestra una lista de todos los usuarios del sistema.
 * - Permite a un administrador realizar acciones sobre ellos (editar rol, eliminar).
 * * * 2. Seguridad (MUY IMPORTANTE):
 * - Esta vista NO implementa la seguridad por sí misma.
 * - Asume que el usuario que la está viendo YA HA SIDO VERIFICADO como 'Admin'.
 * - Debes implementar la lógica de verificación *ANTES* de navegar a esta página.
 * (Ver el ejemplo en la documentación de la respuesta).
 * * * 3. Datos:
 * - Actualmente usa una lista de datos de ejemplo (`_mockUsers`).
 * - En una app real, deberías reemplazar esta lista con una llamada a tu
 * backend (Firebase, API REST, etc.) dentro de un `FutureBuilder` o
 * un `StatefulWidget` con `initState`.
 */

/// Modelo simple para representar un usuario.
/// En tu app, esto debería venir de tu sistema de modelos.
class _User {
  final String id;
  String name;
  String email;
  String role; // Ej. "Admin", "Vendedor", "Cliente"

  _User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });
}

/// Página principal para la gestión de usuarios.
/// Usamos StatefulWidget para poder modificar la lista de usuarios (ej. al eliminar).
class AdminUserManagementPage extends StatefulWidget {
  @override
  _AdminUserManagementPageState createState() =>
      _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage> {
  // --- DATOS DE EJEMPLO ---
  // Reemplaza esto con la carga de datos desde tu backend.
  final List<_User> _users = [
    _User(
        id: '1',
        name: 'Admin Principal',
        email: 'admin@app.com',
        role: 'Admin'),
    _User(
        id: '2',
        name: 'Juan Pérez',
        email: 'juan.perez@correo.com',
        role: 'Vendedor'),
    _User(
        id: '3',
        name: 'Maria García',
        email: 'maria.g@correo.com',
        role: 'Editor'),
    _User(
        id: '4',
        name: 'Carlos Ruiz',
        email: 'c.ruiz@correo.com',
        role: 'Vendedor'),
    _User(
        id: '5',
        name: 'Ana López',
        email: 'ana.lopez@cliente.com',
        role: 'Cliente'),
  ];

  /// Lista de roles disponibles en el sistema.
  final List<String> _rolesDisponibles = ['Admin', 'Vendedor', 'Editor', 'Cliente'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestionar Usuarios'),
        actions: [
          // Botón para añadir un nuevo usuario
          IconButton(
            icon: Icon(Icons.person_add_alt_1),
            tooltip: 'Añadir Usuario',
            onPressed: _addNewUser, // Llama a la función para añadir
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColorLight,
                child: Text(
                  user.name.substring(0, 1), // Muestra la inicial
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColorDark),
                ),
              ),
              title: Text(user.name, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${user.email}\nRol: ${user.role}'),
              isThreeLine: true, // Permite más espacio para el subtítulo
              // Botones de acción a la derecha
              trailing: Row(
                mainAxisSize: MainAxisSize
                    .min, // Hace que el Row ocupe solo el espacio necesario
                children: [
                  // Botón de Editar Rol
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue[600]),
                    tooltip: 'Editar Rol',
                    onPressed: () => _showEditRoleDialog(context, user),
                  ),
                  // Botón de Eliminar Usuario
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red[600]),
                    tooltip: 'Eliminar Usuario',
                    onPressed: () => _showDeleteConfirmDialog(context, user),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Muestra un diálogo de confirmación antes de eliminar un usuario.
  void _showDeleteConfirmDialog(BuildContext context, _User user) {
    // Evita que el admin se elimine a sí mismo (medida de seguridad)
    if (user.email == 'admin@app.com') { // Deberías usar user.id y el id del auth
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('No puedes eliminar al administrador principal.'),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmar Eliminación'),
        content: Text(
            '¿Estás seguro de que deseas eliminar a ${user.name}? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
            onPressed: () {
              // --- LÓGICA DE ELIMINACIÓN ---
              // Aquí llamarías a tu API o base de datos para eliminar al usuario
              // ...
              // Luego, actualizas el estado local para que desaparezca de la lista
              setState(() {
                _users.remove(user);
              });
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Usuario ${user.name} eliminado.'),
                backgroundColor: Colors.green,
              ));
            },
          ),
        ],
      ),
    );
  }

  /// Muestra un diálogo para cambiar el rol de un usuario.
  void _showEditRoleDialog(BuildContext context, _User user) {
    String rolSeleccionado = user.role; // Rol actual como valor inicial

    showDialog(
      context: context,
      builder: (ctx) {
        // Usamos StatefulBuilder para que el Dropdown pueda actualizar
        // su estado *dentro* del diálogo (que es stateless).
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Editar Rol'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Usuario: ${user.name}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Text('Selecciona el nuevo rol:'),
                  SizedBox(height: 8),
                  DropdownButton<String>(
                    value: rolSeleccionado,
                    isExpanded: true,
                    items: _rolesDisponibles.map((String rol) {
                      return DropdownMenuItem<String>(
                        value: rol,
                        child: Text(rol),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setDialogState(() {
                          rolSeleccionado = newValue;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Cancelar'),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                TextButton(
                  child: Text('Guardar'),
                  onPressed: () {
                    // --- LÓGICA DE ACTUALIZACIÓN ---
                    // Aquí llamarías a tu API para guardar el nuevo rol
                    // ...
                    // Luego, actualizas el estado local
                    setState(() {
                      user.role = rolSeleccionado;
                    });
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Rol de ${user.name} actualizado.'),
                      backgroundColor: Colors.green,
                    ));
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Lógica para añadir un nuevo usuario (placeholder).
  void _addNewUser() {
    // Esto es un placeholder.
    // En una app real, navegarías a una nueva pantalla (ej. 'CreateUserPage')
    // o mostrarías un diálogo complejo para rellenar los datos del nuevo usuario.
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Navegando a la pantalla de creación de usuario...'),
    ));
    // Ejemplo:
    // Navigator.push(context, MaterialPageRoute(builder: (ctx) => CreateUserPage()));
  }
}