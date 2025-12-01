import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/models/permission_model.dart';
import 'package:sicv_flutter/models/role_model.dart';
import 'package:sicv_flutter/providers/role_provider.dart';
import 'package:sicv_flutter/providers/permission_provider.dart';

class RoleEditView extends ConsumerStatefulWidget {
  final RoleModel? role;

  const RoleEditView({super.key, this.role});

  @override
  RoleEditViewState createState() => RoleEditViewState();
}

class RoleEditViewState extends ConsumerState<RoleEditView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  late Set<int> _selectedPermissionIds;
  late List<PermissionModel> _rolePermissions;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.role?.name ?? '');

    // Inicializar permisos locales
    _selectedPermissionIds =
        widget.role?.permissions.map((perm) => perm.permissionId).toSet() ?? {};
    // Copiamos la lista para no mutar el objeto original del provider directamente
    _rolePermissions = List.from(widget.role?.permissions ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Lógica para guardar usando el Notifier
  Future<void> _saveRole() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() => _isSaving = true);

    final roleName = _nameController.text;
    final permissionIds = _selectedPermissionIds.toList();

    try {
      // LLAMADA AL NOTIFIER (NO AL SERVICIO DIRECTAMENTE)
      if (widget.role == null) {
        // Crear
        await ref.read(rolesProvider.notifier).createRole(
          name: roleName,
          permissionIds: permissionIds,
        );
      } else {
        // Actualizar
        await ref.read(rolesProvider.notifier).updateRole(
          id: widget.role!.rolId,
          name: roleName,
          permissionIds: permissionIds,
        );
      }

      // El notifier ya se encarga de hacer el refresh(), así que solo notificamos éxito.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rol guardado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos el nuevo permissionsProvider
    final asyncAllPermissions = ref.watch(permissionsProvider);
    final bool isUpdating = widget.role != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isUpdating ? 'Editar Rol' : 'Crear Rol'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              ),
            )
          else
            IconButton(icon: const Icon(Icons.save), onPressed: _saveRole),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Rol',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.shield),
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty) ? 'Requerido' : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          
          // Header de Permisos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Permisos Asignados (${_rolePermissions.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                // Botón secundario para limpiar si quieres
              ],
            ),
          ),
          const Divider(),
          
          // Lista local de permisos seleccionados
          Expanded(
            child: _rolePermissions.isEmpty
                ? Center(
                    child: Text(
                      'Sin permisos asignados',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    itemCount: _rolePermissions.length,
                    itemBuilder: (context, index) {
                      final permission = _rolePermissions[index];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.verified_user, color: AppColors.primary, size: 20),
                        title: Text(permission.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(permission.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _rolePermissions.removeAt(index);
                              _selectedPermissionIds.remove(permission.permissionId);
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Agregar Permiso',
        onPressed: () => _showAddPermissionDialog(asyncAllPermissions),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Diálogo para seleccionar permisos desde el provider
  Future<void> _showAddPermissionDialog(
    AsyncValue<List<PermissionModel>> asyncAllPermissions,
  ) async {
    final PermissionModel? selectedPermission = await showDialog<PermissionModel>(
      context: context,
      builder: (dialogContext) {
        return asyncAllPermissions.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => AlertDialog(
            title: const Text('Error'),
            content: Text('$err'),
            actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('OK'))],
          ),
          data: (allPermissions) {
            // Filtrar los que ya tengo agregados
            final availablePermissions = allPermissions.where((perm) {
              return !_selectedPermissionIds.contains(perm.permissionId);
            }).toList();

            if (availablePermissions.isEmpty) {
              return AlertDialog(
                title: const Text('Aviso'),
                content: const Text('Ya has asignado todos los permisos disponibles.'),
                actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('OK'))],
              );
            }

            return AlertDialog(
              title: const Text('Seleccionar Permiso'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: availablePermissions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final perm = availablePermissions[index];
                    return ListTile(
                      title: Text(perm.name),
                      subtitle: Text(perm.description, style: const TextStyle(fontSize: 12)),
                      onTap: () => Navigator.pop(dialogContext, perm),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (selectedPermission != null) {
      setState(() {
        _rolePermissions.add(selectedPermission);
        _selectedPermissionIds.add(selectedPermission.permissionId);
      });
    }
  }
}