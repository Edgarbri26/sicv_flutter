import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/button_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/text_field_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/drop_down_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/search_text_field_app.dart';

class _User {
  final String id;
  String name;
  String email;
  String role;

  _User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });
}

class AdminUserManagementPage extends StatefulWidget {
  const AdminUserManagementPage({super.key});

  @override
  _AdminUserManagementPageState createState() =>
      _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage> {
  final List<_User> _users = [
    _User(
      id: '1',
      name: 'Admin Principal',
      email: 'admin@app.com',
      role: 'Admin',
    ),
    _User(
      id: '2',
      name: 'Juan Pérez',
      email: 'juan.perez@correo.com',
      role: 'Vendedor',
    ),
    _User(
      id: '3',
      name: 'Maria García',
      email: 'maria.g@correo.com',
      role: 'Editor',
    ),
    _User(
      id: '4',
      name: 'Carlos Ruiz',
      email: 'c.ruiz@correo.com',
      role: 'Vendedor',
    ),
    _User(
      id: '5',
      name: 'Ana López',
      email: 'ana.lopez@cliente.com',
      role: 'Cliente',
    ),
    _User(
      id: '6',
      name: 'Pedro Martinez',
      email: 'p.martinez@correo.com',
      role: 'Editor',
    ),
  ];

  final List<String> _rolesDisponibles = [
    'Todas',
    'Admin',
    'Vendedor',
    'Editor',
    'Cliente',
  ];

  // --- Variables de Estado para Filtros y Orden ---
  late List<_User> _filteredUsers;
  String _searchQuery = '';
  String _selectedRole = 'Todas';
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _filteredUsers = _users;
  }

  /// Filtra Y ORDENA la lista de usuarios
  void _filterUsers() {
    setState(() {
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
            .where(
              (user) =>
                  user.name.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  user.email.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
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
      appBar: const AppBarApp(
        title: 'Gestionar Usuarios',
        iconColor: Colors.black,
        toolbarHeight: 64.0,
      ),
      body: Column(
        children: [
          _buildFiltersAndSearch(),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 3.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewUser,
        tooltip: 'Agregar Usuario',
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.add),
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
            return Row(
              children: [
                Expanded(flex: 2, child: _buildSearchField()),
                const SizedBox(width: 16),
                Expanded(flex: 1, child: _buildRoleFilter()),
              ],
            );
          } else {
            return Column(
              children: [
                _buildSearchField(),
                const SizedBox(height: 16),
                _buildRoleFilter(),
              ],
            );
          }
        },
      ),
    );
  }

  /// Widget de ayuda para el campo de búsqueda
  Widget _buildSearchField() {
    return SearchTextFieldApp(
      labelText: 'Buscar por Nombre o Email',
      hintText: 'Escribe el nombre o email del usuario',
      prefixIcon: Icons.search,
      onChanged: (value) {
        _searchQuery = value;
        _filterUsers();
      },
    );
  }

  /// Widget de ayuda para el filtro de rol
  Widget _buildRoleFilter() {
    return DropDownApp<String>(
      labelText: 'Filtrar por Rol',
      prefixIcon: Icons.filter_list,
      initialValue: _selectedRole,
      items: _rolesDisponibles,
      itemToString: (role) => role,
      onChanged: (newValue) {
        if (newValue == null) return;
        setState(() {
          _selectedRole = newValue;
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
      dataRowColor: WidgetStateProperty.all(AppColors.background),
      headingRowColor: WidgetStateProperty.all(AppColors.border),
      headingRowHeight: 48.0,

      columns: [
        DataColumn(
          label: const Text(
            'Usuario',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onSort: _onSort,
        ),
        DataColumn(
          label: const Text(
            'Email',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onSort: _onSort,
        ),
        DataColumn(
          label: const Text(
            'Rol',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onSort: _onSort,
        ),
        const DataColumn(
          label: Text(
            'Acciones',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],

      rows: _filteredUsers.map((user) {
        return DataRow(
          cells: [
            DataCell(
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    user.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            DataCell(Text(user.email)),
            DataCell(Text(user.role)),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    tooltip: 'Editar Rol',
                    onPressed: () => _showEditRoleDialog(context, user),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
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

  void _showDeleteConfirmDialog(BuildContext context, _User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Usuario'),
          content: Text('¿Estás seguro de que deseas eliminar a ${user.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _users.remove(user);
                  _filterUsers();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Usuario ${user.name} eliminado'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditRoleDialog(BuildContext context, _User user) {
    String? nuevoRol = user.role;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Rol de Usuario'),
          content: DropDownApp<String>(
            labelText: 'Seleccionar Rol',
            initialValue: user.role,
            items: _rolesDisponibles.where((r) => r != 'Todas').toList(),
            itemToString: (role) => role,
            onChanged: (value) {
              if (value != null) nuevoRol = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            PrimaryButtonApp(
              text: 'Guardar',
              onPressed: () {
                if (nuevoRol != null) {
                  setState(() {
                    user.role = nuevoRol!;
                    _filterUsers();
                  });
                }
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Rol de ${user.name} actualizado a $nuevoRol',
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _addNewUser() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    String? selectedRole;
    bool isPasswordObscure = true;

    final bool? userWasAdded = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext modalContext) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.person_add,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Registrar Nuevo Usuario',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Completa los datos del nuevo usuario',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  // Formulario
                  TextFieldApp(
                    controller: nameController,
                    labelText: 'Nombre Completo *',
                    prefixIcon: Icons.person,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  TextFieldApp(
                    controller: emailController,
                    labelText: 'Correo Electrónico *',
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: isPasswordObscure,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.secondary,
                      labelText: 'Contraseña *',
                      prefixIcon: const Icon(Icons.lock, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordObscure
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setStateModal(() {
                            isPasswordObscure = !isPasswordObscure;
                          });
                        },
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          width: 3.0,
                          color: AppColors.border,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          width: 3.0,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropDownApp<String>(
                    labelText: 'Rol *',
                    prefixIcon: Icons.work,
                    items: _rolesDisponibles
                        .where((r) => r != 'Todas')
                        .toList(),
                    itemToString: (role) => role,
                    onChanged: (value) {
                      setStateModal(() => selectedRole = value);
                    },
                  ),
                  const SizedBox(height: 32),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(modalContext).pop(false);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PrimaryButtonApp(
                          text: 'Guardar',
                          icon: Icons.save,
                          onPressed: () {
                            if (nameController.text.isEmpty ||
                                emailController.text.isEmpty ||
                                passwordController.text.isEmpty ||
                                selectedRole == null) {
                              return;
                            }

                            final newUser = _User(
                              id: '${_users.length + 1}',
                              name: nameController.text,
                              email: emailController.text,
                              role: selectedRole!,
                            );
                            setState(() {
                              _users.add(newUser);
                              _filterUsers();
                            });
                            Navigator.of(modalContext).pop(true);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();

    if (userWasAdded == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Usuario agregado correctamente'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}
