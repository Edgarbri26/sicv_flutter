// screens/role_edit_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/models/permission_model.dart';
import 'package:sicv_flutter/models/role_model.dart';
import 'package:sicv_flutter/providers/role_provider.dart';

class RoleEditView extends ConsumerStatefulWidget {
  /// Si [role] es null, estamos en modo "Crear".
  /// Si no es null, estamos en modo "Actualizar".
  final RoleModel? role;

  const RoleEditView({super.key, this.role});

  @override
  RoleEditViewState createState() => RoleEditViewState();
}

class RoleEditViewState extends ConsumerState<RoleEditView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  // Usamos un Set para almacenar los IDs de los permisos seleccionados.
  // Es mucho más eficiente (O(1)) para verificar si un permiso está
  // seleccionado que usar una Lista (O(n)).
  late Set<int> _selectedPermissionIds;
  late List<Permission> _rolePermissions;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.role?.name ?? '');

    // Si estamos editando, poblamos el Set con los permisos existentes.
    _selectedPermissionIds =
        widget.role?.permissions.map((perm) => perm.permissionId).toSet() ?? {};
    _rolePermissions = widget.role?.permissions ?? [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Lógica para guardar (Crear o Actualizar)
  Future<void> _saveRole() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    final roleService = ref.read(roleServiceProvider);
    final roleName = _nameController.text;
    final permissionIds = _selectedPermissionIds.toList();

    try {
      if (widget.role == null) {
        // --- Modo Crear ---
        await roleService.createRole(roleName, permissionIds);
      } else {
        // --- Modo Actualizar ---
        await roleService.updateRole(
          widget.role!.rolId,
          roleName,
          permissionIds,
        );
      }

      // Si todo sale bien:
      // 1. Invalidamos el caché de la lista de roles para que se actualice
      ref.invalidate(allRolesProvider);

      // 2. Mostramos un SnackBar de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rol guardado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      // 3. Cerramos la pantalla
      Navigator.pop(context);
    } catch (e) {
      // Manejo de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar el rol: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos la lista maestra de TODOS los permisos
    final asyncAllPermissions = ref.watch(allPermissionsProvider);

    final bool isUpdating = widget.role != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isUpdating ? 'Editar Rol' : 'Crear Rol'),
        actions: [
          // Botón de Guardar
          if (!_isSaving)
            IconButton(icon: const Icon(Icons.save), onPressed: _saveRole),
          // Indicador de carga mientras se guarda
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Rol',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shield),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- SECCIÓN DE PERMISOS ---
          Text(
            'Permisos Asignados',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _rolePermissions.length,
              itemBuilder: (context, index) {
                final permission = _rolePermissions[index];
                return ListTile(
                  hoverColor: AppColors.primary.withOpacity(0.1),
                  leading: const Icon(
                    Icons.verified_user,
                    color: AppColors.primary,
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      setState(() {
                        _rolePermissions.removeAt(index);
                        _selectedPermissionIds.remove(permission.permissionId);
                      });
                    },
                    icon: Icon(Icons.delete),
                  ),
                  title: Text(permission.name),
                  onTap: () {},
                  subtitle: Text(permission.description),
                );
              },
            ),
            // child: ListView.builder(
            //   // Importante: Deshabilitar scroll y encoger
            //   // physics: const NeverScrollableScrollPhysics(),
            //   shrinkWrap: true,
            //   itemCount: _rolePermissions.length,
            //   itemBuilder: (context, index) {
            //     final permission = _rolePermissions[index];
            //     final bool isSelected = _selectedPermissionIds.contains(
            //       permission.permissionId,
            //     );

            //     return CheckboxListTile(
            //       title: Text(permission.name),
            //       subtitle: Text(permission.description),
            //       value: isSelected,
            //       onChanged: (bool? newValue) {
            //         setState(() {
            //           if (newValue == true) {
            //             _selectedPermissionIds.add(permission.permissionId);
            //           } else {
            //             _selectedPermissionIds.remove(permission.permissionId);
            //           }
            //         });
            //       },
            //     );
            //   },
            // ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddPermissionDialog(asyncAllPermissions);
        },
        tooltip: 'Agregar Permiso',
        child: const Icon(Icons.add),
      ),
    );
  }

  // Coloca esto dentro de tu clase RoleEditViewState

  /// Muestra un diálogo para seleccionar y agregar un permiso al rol.
  Future<void> _showAddPermissionDialog(
    AsyncValue<List<Permission>> asyncAllPermissions,
  ) async {
    // Esperamos a que el diálogo se cierre y nos devuelva un permiso (o null)
    final Permission? selectedPermission = await showDialog<Permission>(
      context: context,
      builder: (dialogContext) {
        // Usamos .when para manejar los 3 estados del provider
        return asyncAllPermissions.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => AlertDialog(
            title: const Text('Error'),
            content: Text('No se pudieron cargar los permisos: $err'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cerrar'),
              ),
            ],
          ),
          data: (allPermissions) {
            // --- Lógica Clave ---
            // Filtramos la lista maestra para mostrar solo los permisos
            // que NO están ya en nuestro Set _selectedPermissionIds.
            final availablePermissions = allPermissions.where((perm) {
              return !_selectedPermissionIds.contains(perm.permissionId);
            }).toList();

            if (availablePermissions.isEmpty) {
              return AlertDialog(
                title: const Text('Agregar Permiso'),
                content: const Text(
                  'No hay más permisos disponibles para agregar.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cerrar'),
                  ),
                ],
              );
            }

            // Construimos el diálogo con la lista filtrada
            return AlertDialog(
              title: const Text('Seleccionar Permiso'),
              // Usamos un Container para que el ListView tenga un tamaño definido
              content: SizedBox(
                width: double.maxFinite,
                // Usamos un ListView.builder para la eficiencia
                child: ListView.builder(
                  shrinkWrap: true, // Se adapta al contenido
                  itemCount: availablePermissions.length,
                  itemBuilder: (context, index) {
                    final perm = availablePermissions[index];
                    return ListTile(
                      title: Text(perm.name),
                      subtitle: Text(perm.description),
                      onTap: () {
                        // Al seleccionar, cerramos el diálogo y
                        // devolvemos el permiso elegido.
                        Navigator.pop(dialogContext, perm);
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(dialogContext), // Devuelve null
                  child: const Text('Cancelar'),
                ),
              ],
            );
          },
        );
      },
    );

    // --- Después de que el diálogo se cierra ---
    if (selectedPermission != null) {
      // Si el usuario seleccionó un permiso, lo agregamos al estado local
      setState(() {
        _rolePermissions.add(selectedPermission);
        _selectedPermissionIds.add(selectedPermission.permissionId);
      });
    }
  }
}
