// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:sicv_flutter/ui/widgets/admin/add_user_form_seet.dart';
import 'package:sicv_flutter/ui/widgets/menu.dart';
// Importa el nuevo formulario que crearemos (mira el paso 2)
// import 'package:tu_proyecto/widgets/admin/add_user_form_sheet.dart';

/// Modelo simple para representar un usuario.
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
class AdminUserManagementPage extends StatefulWidget {
  @override
  _AdminUserManagementPageState createState() =>
      _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage> {
  // --- DATOS DE EJEMPLO ---
  final List<_User> _users = [
    _User(id: '1', name: 'Admin Principal', email: 'admin@app.com', role: 'Admin'),
    _User(id: '2', name: 'Juan Pérez', email: 'juan.perez@correo.com', role: 'Vendedor'),
    _User(id: '3', name: 'Maria García', email: 'maria.g@correo.com', role: 'Editor'),
    _User(id: '4G', name: 'Carlos Ruiz', email: 'c.ruiz@correo.com', role: 'Vendedor'),
    _User(id: '5', name: 'Ana López', email: 'ana.lopez@cliente.com', role: 'Cliente'),
    _User(id: '6', name: 'Pedro Martinez', email: 'p.martinez@correo.com', role: 'Editor'),
  ];

  /// Lista de roles disponibles en el sistema.
  final List<String> _rolesDisponibles = ['Todas', 'Admin', 'Vendedor', 'Editor', 'Cliente'];
  
  // --- Variables de Estado para Filtros y Orden ---
  late List<_User> _filteredUsers;
  String _searchQuery = '';
  String _selectedRole = 'Todas';
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    // Al iniciar, la lista filtrada es igual a la lista completa
    _filteredUsers = _users;
    // En una app real, aquí llamarías a tu API para cargar los usuarios
  }

  /// Filtra Y ORDENA la lista de usuarios
  void _filterUsers() {
    setState(() {
      // 1. Empezar siempre desde la lista completa
      List<_User> tempUsers = _users;

      // 2. Filtrar por Rol
      if (_selectedRole != 'Todas') {
        tempUsers = tempUsers
            .where((user) => user.role == _selectedRole)
            .toList();
      }

      // 3. Filtrar por Búsqueda (Nombre o Email)
      if (_searchQuery.isNotEmpty) {
        tempUsers = tempUsers
            .where((user) =>
                user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                user.email.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();
      }

      // 4. Aplicar Ordenamiento
      if (_sortColumnIndex != null) {
        tempUsers.sort((a, b) {
          dynamic aValue;
          dynamic bValue;

          switch (_sortColumnIndex) {
            case 0: // Usuario (Nombre)
              aValue = a.name.toLowerCase();
              bValue = b.name.toLowerCase();
              break;
            case 1: // Email
              aValue = a.email.toLowerCase();
              bValue = b.email.toLowerCase();
              break;
            case 2: // Rol
              aValue = a.role.toLowerCase();
              bValue = b.role.toLowerCase();
              break;
            default:
              return 0;
          }

          final comparison = aValue.compareTo(bValue);
          return _sortAscending ? comparison : -comparison;
        });
      }

      _filteredUsers = tempUsers;
    });
  }

  /// Se llama cuando el usuario hace clic en un encabezado
  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _filterUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestionar Usuarios'),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add_alt_1),
            tooltip: 'Añadir Usuario',
            onPressed: _addNewUser, // ¡Esta función ahora es "chévere"!
          ),
        ],
      ),
      drawer: const Menu(),
      body: Column(
        children: [
          // --- SECCIÓN DE FILTROS ---
          _buildFiltersAndSearch(),

          // --- SECCIÓN DE TABLA ---
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: Card(
                margin: const EdgeInsets.all(16.0),
                clipBehavior: Clip.antiAlias,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: constraints.maxWidth),
                        child: _buildDataTable(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la barra de búsqueda y filtro (RESPONSIVO)
  Widget _buildFiltersAndSearch() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;

          if (isWideScreen) {
            return Row(children: [
              Expanded(flex: 2, child: _buildSearchField()),
              SizedBox(width: 16),
              Expanded(flex: 1, child: _buildRoleFilter()),
            ]);
          } else {
            return Column(children: [
              _buildSearchField(),
              SizedBox(height: 16),
              _buildRoleFilter(),
            ]);
          }
        },
      ),
    );
  }

  /// Widget de ayuda para el campo de búsqueda
  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Buscar por Nombre o Email',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      ),
      onChanged: (value) {
        _searchQuery = value;
        _filterUsers();
      },
    );
  }

  /// Widget de ayuda para el filtro de rol
  Widget _buildRoleFilter() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Filtrar por Rol',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      ),
      initialValue: _selectedRole,
      items: _rolesDisponibles.map((String role) {
        return DropdownMenuItem<String>(
          value: role,
          child: Text(role),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedRole = newValue!;
        });
        _filterUsers();
      },
    );
  }

  /// Construye el DataTable
  Widget _buildDataTable() {
    return DataTable(
      horizontalMargin: 12.0,
      columnSpacing: 20.0,
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      
      columns: [
        DataColumn(
          label: Text('Usuario', style: TextStyle(fontWeight: FontWeight.bold)),
          onSort: _onSort, // Índice 0
        ),
        DataColumn(
          label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
          onSort: _onSort, // Índice 1
        ),
        DataColumn(
          label: Text('Rol', style: TextStyle(fontWeight: FontWeight.bold)),
          onSort: _onSort, // Índice 2
        ),
        DataColumn(
          label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold)),
          // Sin 'onSort'
        ),
      ],
      
      rows: _filteredUsers.map((user) {
        return DataRow(
          cells: [
            // Celda 0: Usuario (Nombre + Avatar)
            DataCell(
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).primaryColorLight,
                    child: Text(
                      user.name.substring(0, 1),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(user.name, style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            // Celda 1: Email
            DataCell(Text(user.email)),
            // Celda 2: Rol
            DataCell(Text(user.role)),
            // Celda 3: Acciones
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, size: 20, color: Colors.blue.shade700),
                    tooltip: 'Editar Rol',
                    onPressed: () => _showEditRoleDialog(context, user),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, size: 20, color: Colors.red.shade700),
                    tooltip: 'Eliminar Usuario',
                    onPressed: () => _showDeleteConfirmDialog(context, user),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  // --- Diálogos (Sin cambios) ---
  // (Tu código para _showDeleteConfirmDialog y _showEditRoleDialog
  // está perfecto, así que puedes pegarlo aquí sin modificar)

  /// Muestra un diálogo de confirmación antes de eliminar un usuario.
  void _showDeleteConfirmDialog(BuildContext context, _User user) {
     // ... (Pega tu código existente aquí) ...
  }

  /// Muestra un diálogo para cambiar el rol de un usuario.
  void _showEditRoleDialog(BuildContext context, _User user) {
     // ... (Pega tu código existente aquí) ...
  }

  /// Lógica para añadir un nuevo usuario (¡Mejorada!)
  void _addNewUser() async {
    // Muestra el panel flotante
    final bool? userWasAdded = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7, // 70%
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            // Llama al nuevo widget de formulario
            return AddUserFormSheet(
              scrollController: scrollController,
              rolesDisponibles: _rolesDisponibles.where((r) => r != 'Todas').toList(), // Pasa la lista de roles
            );
          },
        );
      },
    );

    if (userWasAdded == true) {
      // Si el formulario devolvió 'true', refrescamos la lista
      // (Aquí llamarías a tu API para recargar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usuario añadido (simulado). Actualizando lista...'),
          backgroundColor: Colors.green,
        ),
      );
      // _filterUsers(); // Llama a esto después de recargar tus datos
    }
  }
}