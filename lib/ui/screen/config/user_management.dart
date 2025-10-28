// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/ui/widgets/admin/add_user_form_seet.dart';
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
        // 1. Apariencia limpia: Fondo blanco/claro y sin elevación marcada
        backgroundColor: Theme.of(context).colorScheme.surface, // Usa el color de fondo del tema
        surfaceTintColor: Colors.transparent, // Elimina el tinte al hacer scroll (Android 12+)
        elevation: 0, // 0 para un look plano y moderno

        // 2. Título estilizado
        title: Text("Gestionar Usuarios",
          style: TextStyle(
            fontWeight: FontWeight.bold, // Título en negrita
            fontSize: 20,
            color: Theme.of(context).colorScheme.onSurface, // Color de texto basado en el tema
          ),
        ),
        
        // 3. Altura de la barra (opcional pero profesional)
        toolbarHeight: 64.0, // Un poco más de altura para un mejor 'feel'

        // 4. Integración con la interfaz de usuario (Buscador y Ajuste Manual)
        // Nota: Si el FAB (Ajuste Manual) está en la parte inferior, puedes dejar esto vacío.
        // Si deseas una acción de ícono en la AppBar, úsala aquí.
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.add_circle_outline),
          //   onPressed: () => _showAddMovementModal(context),
          //   tooltip: 'Registrar Ajuste Manual',
          // ),
          const SizedBox(width: 16), // Espacio al final
        ],
        
        // 5. Configuración de Tema (para íconos y otros elementos)
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.primary, // Íconos con color primario del tema
        ),
      ),
      //drawer: const Menu(),
      body: Column(
        children: [
          // --- SECCIÓN DE FILTROS ---
          _buildFiltersAndSearch(),

          // --- SECCIÓN DE TABLA ---
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: Card(
                elevation: 0.0, 
                // 2. Define el borde exterior usando 'shape'
                shape: RoundedRectangleBorder(
                  // Define el radio de las esquinas
                  borderRadius: BorderRadius.circular(8.0), 
                  
                  // Define el borde (grosor y color)
                  side: BorderSide(
                    color: AppColors.border, // El color del borde
                      width: 3.0,                // El grosor del borde
                    ),
                ),
                clipBehavior: Clip.antiAlias, // Evita que la tabla se salga
                margin: const EdgeInsets.all(16.0),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewUser,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.primary,)),
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
        filled: true,
        fillColor: AppColors.secondary,
        labelText: 'Buscar por Nombre o SKU',
        prefixIcon: Icon(Icons.search),
        labelStyle: TextStyle(
          fontSize: 14.0, // <-- Cambia el tamaño de la fuente del label
          color: AppColors.textSecondary, // (Opcional: define el color del label)
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            width: 2.0, // <-- Tu grosor deseado
            color: AppColors.border, // Color del borde
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              width: 3.0, // <-- Puedes poner un grosor mayor al enfocar
              color: AppColors.textSecondary, // Color del borde al enfocar
          ),
        ),
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
    // --- 3. CORRECCIÓN DEL BUG DE OVERFLOW ---
    // Esto evita que el texto se desborde (rayas amarillas/negras)
    isExpanded: true, 

    decoration: InputDecoration(
      filled: true,
      fillColor: AppColors.secondary,
      
      // --- 1. CORRECCIÓN DE LÓGICA ---
      labelText: 'Filtrar por Rol', // <--- Texto corregido
      prefixIcon: Icon(Icons.filter_list), // <--- Ícono corregido
      
      labelStyle: TextStyle(
        fontSize: 14.0, 
        color: AppColors.textSecondary,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          width: 2.0, 
          color: AppColors.border, 
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          width: 3.0, 
          color: AppColors.textSecondary,
        ),
      ),
    ),
    
    // --- Lógica del Dropdown (esto estaba bien) ---
    initialValue: _selectedRole, // Usa 'value' en lugar de 'initialValue' para DropdownButtonFormField
    items: _rolesDisponibles.map((String role) {
      return DropdownMenuItem<String>(
        value: role,
        child: Text(
          role,
          overflow: TextOverflow.ellipsis, // Previene overflow del texto en el menú
        ),
      );
    }).toList(),
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

      dataRowColor: WidgetStateProperty.all(AppColors.background), // Color de fondo de las filas
      headingRowColor: WidgetStateProperty.all(AppColors.border), // Color de fondo de la cabecera
      //dataRowHeight: 60.0, // <-- Altura fija para las filas (útil para imágenes)
      headingRowHeight: 48.0, // <-- Altura fija para la cabecera
      
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
 // Asegúrate de que _rolesDisponibles exista en tu clase de Estado,
// por ejemplo:
// final List<String> _rolesDisponibles = ['Admin', 'Vendedor', 'Cliente', 'Todas'];

void _addNewUser() async {
  // --- Controllers ---
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // --- Variables de estado para el modal ---
  String? selectedRole;
  bool isPasswordObscure = true;

  // Muestra el panel flotante
  final bool? userWasAdded = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext modalContext) {
      // 1. Padding para que el teclado no tape el formulario
      return Padding(
        padding: MediaQuery.of(modalContext).viewInsets,
        // 2. StatefulBuilder para manejar el estado interno del modal
        child: StatefulBuilder(
          builder: (context, setStateModal) {
            return Container(
              // Altura ajustada (un poco menos que productos, ya que no hay imagen)
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // --- Título del Modal ---
                  Text(
                    'Registrar Nuevo Usuario',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 24),

                  // --- Cuerpo del Formulario ---
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 16),
                          // --- Campos del Formulario usando el helper ---
                          _buildCustomTextField(
                            controller: nameController,
                            labelText: 'Nombre Completo',
                            prefixIcon: Icons.person_outline,
                            keyboardType: TextInputType.name,
                          ),
                          const SizedBox(height: 16),
                          _buildCustomTextField(
                            controller: emailController,
                            labelText: 'Correo Electrónico',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),

                          // --- Campo de Contraseña (manual para añadir suffixIcon) ---
                          TextField(
                            controller: passwordController,
                            obscureText: isPasswordObscure,
                            keyboardType: TextInputType.visiblePassword,
                            decoration: _buildInputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: Icons.lock_outline,
                            ).copyWith(
                              // Usamos .copyWith para añadir el suffixIcon
                              // sin modificar tu helper original
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordObscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
                                onPressed: () {
                                  // Actualiza el estado solo del modal
                                  setStateModal(() {
                                    isPasswordObscure = !isPasswordObscure;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // --- Dropdown para Roles ---
                          DropdownButtonFormField<String>(
                            value: selectedRole,
                            decoration: _buildInputDecoration(labelText: 'Rol'),
                            // Usamos los mismos estilos que los TextField
                            style: const TextStyle(
                                color: AppColors.textSecondary),
                            dropdownColor: AppColors.secondary,
                            items: _rolesDisponibles
                                .where((r) => r != 'Todas') // Filtra 'Todas'
                                .map((rol) => DropdownMenuItem(
                                      value: rol,
                                      child: Text(rol),
                                    ))
                                .toList(),
                            onChanged: (String? newValue) {
                              setStateModal(() => selectedRole = newValue);
                            },
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // --- Botones de Acción (Copiados de addNewProduct) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TextButton(
                        child: const Text('CANCELAR'),
                        onPressed: () => Navigator.of(modalContext).pop(false),
                      ),
                      const SizedBox(width: 8),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 250,
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          // Deshabilita el botón si faltan campos
                          onPressed: (nameController.text.isEmpty ||
                                  emailController.text.isEmpty ||
                                  passwordController.text.isEmpty ||
                                  selectedRole == null)
                              ? null
                              : () {
                                  // --- Placeholder para tu lógica de API ---
                                  print('--- Guardando Usuario ---');
                                  print('Nombre: ${nameController.text}');
                                  print('Email: ${emailController.text}');
                                  print('Password: [OCULTO]');
                                  print('Rol: $selectedRole');
                                  // 🚨 Llama a tu API aquí
                                  // bool success = await ApiService.saveUser(...);
                                  // --- Fin del Placeholder ---

                                  // Cierra el modal y devuelve 'true'
                                  if (mounted) {
                                    Navigator.of(modalContext).pop(true);
                                  }
                                },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.check, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'GUARDAR USUARIO',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  ).whenComplete(() {
    // 3. Limpia los controllers al cerrar el modal
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
  });

  // 4. Lógica original para manejar el resultado
  if (userWasAdded == true) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Usuario añadido con éxito. Actualizando lista...'),
        backgroundColor: Colors.green,
      ),
    );
    // 🚨 Aquí es donde debes llamar a tu función para refrescar los datos
    // _filterUsers();
  }
}

 InputDecoration _buildInputDecoration({required String labelText, IconData? prefixIcon}) {
    return InputDecoration(
      labelStyle: const TextStyle(
        fontSize: 16.0,
        color: AppColors.textSecondary,
      ),
      filled: true,
      fillColor: AppColors.secondary,
      labelText: labelText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18) : null,
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
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    );
  }

// Widget auxiliar para mantener el código más limpio
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String labelText,
    IconData? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      decoration: _buildInputDecoration(labelText: labelText, prefixIcon: prefixIcon),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.sentences,
    );
  }


}