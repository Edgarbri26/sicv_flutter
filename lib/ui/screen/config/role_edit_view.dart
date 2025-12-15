import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/models/permission_model.dart';
import 'package:sicv_flutter/models/role_model.dart';
import 'package:sicv_flutter/providers/role_provider.dart';
// IMPORTANTE: Importamos el nuevo provider que creamos en el Paso 1
import 'package:sicv_flutter/providers/all_permissions_provider.dart';
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';

class RoleEditView extends ConsumerStatefulWidget {
  final RoleModel? role;

  const RoleEditView({super.key, this.role});

  @override
  ConsumerState<RoleEditView> createState() => _RoleEditViewState();
}

class _RoleEditViewState extends ConsumerState<RoleEditView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  // Estado Local para la edición
  late Set<int> _selectedPermissionIds;
  late List<PermissionModel> _rolePermissions;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.role?.name ?? '');

    // Inicializar permisos locales (copia defensiva para no modificar el state global directamente)
    _selectedPermissionIds =
        widget.role?.permissions.map((p) => p.permissionId).toSet() ?? {};
    _rolePermissions = List.from(widget.role?.permissions ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveRole() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() => _isSaving = true);

    final name = _nameController.text.trim();
    final permissionIds = _selectedPermissionIds.toList();

    try {
      if (widget.role == null) {
        // --- Crear ---
        await ref
            .read(rolesProvider.notifier)
            .createRole(name: name, permissionIds: permissionIds);
      } else {
        // --- Actualizar ---
        await ref
            .read(rolesProvider.notifier)
            .updateRole(
              id: widget.role!.roleId,
              name: name,
              permissionIds: permissionIds,
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('role guardado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // AHORA SÍ: Escuchamos el provider correcto (allPermissionsProvider)
    final asyncAllPermissions = ref.watch(allPermissionsProvider);
    final isEditing = widget.role != null;

    return Scaffold(
      appBar: AppBarApp(
        title: isEditing ? 'Editar role' : 'Nuevo role',
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(icon: const Icon(Icons.save), onPressed: _saveRole),
        ],
      ),
      body: Column(
        children: [
          // Formulario Básico (Nombre)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del role',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shield_outlined),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
            ),
          ),

          // Header de Permisos
          const Divider(thickness: 1, height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Permisos Asignados (${_rolePermissions.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Lista de Permisos Asignados
          Expanded(
            child: _rolePermissions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_open,
                          size: 48,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Sin permisos asignados',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: _rolePermissions.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 16, endIndent: 16),
                    itemBuilder: (context, index) {
                      final perm = _rolePermissions[index];
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.check_circle,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                        title: Text(
                          perm.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          perm.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            setState(() {
                              _rolePermissions.removeAt(index);
                              _selectedPermissionIds.remove(perm.permissionId);
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        // Pasamos el asyncValue al diálogo
        onPressed: () => _showAddPermissionDialog(asyncAllPermissions),
        icon: const Icon(Icons.add),
        label: const Text("Agregar Permiso"),
      ),
    );
  }

  // Diálogo para seleccionar permisos
  Future<void> _showAddPermissionDialog(
    AsyncValue<List<PermissionModel>> asyncPerms,
  ) async {
    final PermissionModel? picked = await showDialog(
      context: context,
      builder: (context) {
        return asyncPerms.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) =>
              AlertDialog(title: const Text("Error"), content: Text("$err")),
          data: (allPermissions) {
            // Filtrar: Mostrar solo los que NO están asignados todavía
            final available = allPermissions
                .where((p) => !_selectedPermissionIds.contains(p.permissionId))
                .toList();

            if (available.isEmpty) {
              return AlertDialog(
                title: const Text("Aviso"),
                content: const Text(
                  "Ya has agregado todos los permisos disponibles.",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              );
            }

            return AlertDialog(
              title: const Text("Seleccionar Permiso"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: available.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final p = available[index];
                    return ListTile(
                      title: Text(p.name),
                      subtitle: Text(
                        p.description,
                        style: const TextStyle(fontSize: 12),
                      ),
                      onTap: () => Navigator.pop(context, p),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
              ],
            );
          },
        );
      },
    );

    if (picked != null) {
      setState(() {
        _rolePermissions.add(picked);
        _selectedPermissionIds.add(picked.permissionId);
      });
    }
  }
}
