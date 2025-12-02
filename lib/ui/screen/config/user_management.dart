import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/models/role_model.dart';
import 'package:sicv_flutter/models/user/user_model.dart';
import 'package:sicv_flutter/providers/role_provider.dart';
import 'package:sicv_flutter/providers/user_management_provider.dart'; // El nuevo provider de gestión de usuario
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/button_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/drop_down_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/search_text_field_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/text_field_app.dart';

class AdminUserManagementPage extends ConsumerStatefulWidget {
  const AdminUserManagementPage({super.key});

  @override
  ConsumerState<AdminUserManagementPage> createState() => _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends ConsumerState<AdminUserManagementPage> {
  // Estado local para filtro
  String _searchQuery = '';
  RoleModel? _selectedRoleFilter; 

  @override
  Widget build(BuildContext context) {
    // 1. Escuchamos los datos del backend
    final usersAsync = ref.watch(usersProvider);
    final rolesAsync = ref.watch(rolesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppBarApp(title: 'Gestionar Usuarios'),
      
      // Botón Flotante para Agregar
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () {
          // Solo abrimos el modal si ya cargaron los role
          rolesAsync.whenData((roles) {
            _showAddUserModal(context, roles);
          });
        },
      ),
      
      body: Column(
        children: [
          // --- BARRA DE FILTROS ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SearchTextFieldApp(
                    labelText: 'Buscar por nombre o CI...',
                    prefixIcon: Icons.search,
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: rolesAsync.when(
                    data: (roles) => DropDownApp<RoleModel?>(
                      labelText: "Filtrar Rol",
                      items: [null, ...roles], // null actúa como "Todos"
                      initialValue: _selectedRoleFilter,
                      itemToString: (r) => r?.name ?? "Todos",
                      onChanged: (r) => setState(() => _selectedRoleFilter = r),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_,__) => const SizedBox(),
                  ),
                ),
              ],
            ),
          ),

          // --- TABLA DE USUARIOS ---
          Expanded(
            child: usersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (users) {
                // 1. Aplicamos filtros locales
                final filteredUsers = users.where((u) {
                  final query = _searchQuery.toLowerCase();
                  final matchesSearch = u.name.toLowerCase().contains(query) || 
                                        u.userCi.toLowerCase().contains(query);
                  
                  final matchesRole = _selectedRoleFilter == null || 
                                      u.rolId == _selectedRoleFilter!.rolId;
                                      
                  return matchesSearch && matchesRole;
                }).toList();

                if (filteredUsers.isEmpty) {
                  return const Center(child: Text("No se encontraron usuarios."));
                }

                // 2. Construimos la tabla
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
                        columns: const [
                          DataColumn(label: Text('CI / Cédula', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Rol', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: filteredUsers.map((user) {
                          // Obtenemos lista de roles para pasar al modal de edición
                          final roles = rolesAsync.value ?? []; 
                          
                          return DataRow(cells: [
                            DataCell(Text(user.userCi)),
                            DataCell(Text(user.name)),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(user.rol?.name ?? 'Sin Rol', 
                                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                              ),
                            ),
                            DataCell(
                              Icon(
                                user.status ? Icons.check_circle : Icons.cancel,
                                color: user.status ? Colors.green : Colors.grey,
                                size: 20,
                              )
                            ),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  tooltip: 'Editar Usuario',
                                  onPressed: () => _showEditUserDialog(context, user, roles),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  tooltip: 'Eliminar Usuario',
                                  onPressed: () => _deleteUser(user),
                                ),
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // MODALES Y LÓGICA
  // ===========================================================================

  /// Modal para CREAR Usuario
  void _showAddUserModal(BuildContext context, List<RoleModel> roles) {
    final ciCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    RoleModel? selectedRole;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateModal) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Registrar Nuevo Usuario", style: Theme.of(context).textTheme.headlineSmall),
              const Divider(height: 30),
              
              TextFieldApp(
                controller: ciCtrl, 
                labelText: "Cédula de Identidad",
                prefixIcon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              
              TextFieldApp(
                controller: nameCtrl, 
                labelText: "Nombre Completo",
                prefixIcon: Icons.person_outline,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              
              TextFieldApp(
                controller: passCtrl, 
                labelText: "Contraseña", 
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              
              DropDownApp<RoleModel>(
                labelText: "Asignar Rol",
                prefixIcon: Icons.shield_outlined,
                items: roles,
                initialValue: selectedRole,
                itemToString: (r) => r.name,
                onChanged: (r) => setStateModal(() => selectedRole = r),
              ),
              const SizedBox(height: 32),
              
              PrimaryButtonApp(
                text: "GUARDAR USUARIO",
                icon: Icons.save,
                isLoading: isSaving,
                onPressed: () async {
                  // Validaciones simples
                  if (ciCtrl.text.isEmpty || nameCtrl.text.isEmpty || passCtrl.text.isEmpty || selectedRole == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Todos los campos son obligatorios")));
                    return;
                  }

                  setStateModal(() => isSaving = true);

                  try {
                    await ref.read(usersProvider.notifier).createUser(
                      ciCtrl.text.trim(), 
                      nameCtrl.text.trim(), 
                      passCtrl.text, 
                      selectedRole!.rolId
                    );
                    
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Usuario creado"), backgroundColor: Colors.green));
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
                  } finally {
                    if(mounted) setStateModal(() => isSaving = false);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Modal para EDITAR Usuario (Nombre y Rol)
  void _showEditUserDialog(BuildContext context, UserModel user, List<RoleModel> roles) {
    final nameCtrl = TextEditingController(text: user.name);
    
    // Buscamos el rol actual en la lista para que el dropdown lo reconozca
    RoleModel? selectedRole;
    try {
      selectedRole = roles.firstWhere((r) => r.rolId == user.rolId);
    } catch (_) {
      // Si el rol ya no existe o es null
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Editar: ${user.name}"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFieldApp(
                controller: nameCtrl,
                labelText: "Nombre Completo",
                prefixIcon: Icons.person,
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setStateDialog) => DropDownApp<RoleModel>(
                  labelText: "Rol del Usuario",
                  items: roles,
                  initialValue: selectedRole,
                  itemToString: (r) => r.name,
                  onChanged: (r) => setStateDialog(() => selectedRole = r),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text("Guardar Cambios"),
            onPressed: () async {
              try {
                // Llamamos al método genérico de actualización
                await ref.read(usersProvider.notifier).updateUser(
                  user.userCi,
                  name: nameCtrl.text.trim(),
                  roleId: selectedRole?.rolId,
                );
                
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Usuario actualizado"), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e"), backgroundColor: Colors.red));
              }
            },
          )
        ],
      ),
    );
  }

  /// Lógica de Eliminación
  void _deleteUser(UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmar Eliminación"),
        content: Text("¿Estás seguro de eliminar al usuario '${user.name}'? Esta acción no se puede deshacer."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          TextButton(
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              try {
                await ref.read(usersProvider.notifier).deleteUser(user.userCi);
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Usuario eliminado"), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e"), backgroundColor: Colors.red));
              }
            },
          )
        ],
      ),
    );
  }
}