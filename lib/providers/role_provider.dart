import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sicv_flutter/models/role_model.dart';
import 'package:sicv_flutter/services/role_service.dart';

// 1. Proveedor del Servicio (Inyección de dependencia)
final roleServiceProvider = Provider<RoleService>((ref) {
  return RoleService();
});

// 2. El Notifier (Lógica de Negocio y Estado)
class RolesNotifier extends StateNotifier<AsyncValue<List<RoleModel>>> {
  final RoleService _service;

  RolesNotifier(this._service) : super(const AsyncValue.loading()) {
    loadRoles();
  }

  // Cargar roles inicialmente
  Future<void> loadRoles() async {
    try {
      state = const AsyncValue.loading();
      final roles = await _service.getAllRoles();
      state = AsyncValue.data(roles);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Refrescar lista (útil después de agregar/editar)
  Future<void> refresh() async {
    try {
      // Nota: No ponemos estado en loading para evitar parpadeos en la UI
      final roles = await _service.getAllRoles();
      state = AsyncValue.data(roles);
    } catch (e) {
      print("Error refrescando roles: $e");
    }
  }

  // Crear un nuevo Rol
  Future<void> createRole({
    required String name,
    required List<int> permissionIds, // Lista de IDs de permisos seleccionados
  }) async {
    try {
      await _service.createRole(
        name, 
        permissionIds
        );
      // Recargamos la lista para ver el nuevo rol
      await refresh();
    } catch (e) {
      throw e; // Re-lanzamos para mostrar SnackBar en la vista
    }
  }

  // Actualizar un Rol existente
  Future<void> updateRole({
    required int id,
    required String name,
    required List<int> permissionIds,
  }) async {
    try {
      await _service.updateRole(
        id,
        name,
        permissionIds,
      );
      await refresh();
    } catch (e) {
      throw e;
    }
  }

  // Eliminar (o desactivar) un Rol
  Future<void> deleteRole(int roleId) async {
    // Optimismo: Eliminamos visualmente antes de confirmar (opcional)
    final previousState = state;
    if (state.hasValue) {
      state = AsyncValue.data(
        state.value!.where((r) => r.rolId != roleId).toList(),
      );
    }

    try {
      await _service.deleteRole(roleId);
      // Si el backend devuelve la lista actualizada, podrías usar refresh() aquí también
    } catch (e) {
      // Si falla, revertimos al estado anterior
      state = previousState;
      throw e;
    }
  }
}

// 3. El Proveedor Global
final rolesProvider = StateNotifierProvider<RolesNotifier, AsyncValue<List<RoleModel>>>((ref) {
  final service = ref.watch(roleServiceProvider);
  return RolesNotifier(service);
});