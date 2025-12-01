import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sicv_flutter/models/permission_model.dart';
import 'package:sicv_flutter/services/permission_service.dart';

// 1. Proveedor del Servicio
final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

// 2. El Notifier
class PermissionsNotifier extends StateNotifier<AsyncValue<List<PermissionModel>>> {
  final PermissionService _service;

  PermissionsNotifier(this._service) : super(const AsyncValue.loading()) {
    loadPermissionsByRole();
  }

  // Cargar todos los permisos disponibles
  Future<void> loadPermissionsByRole() async {
    try {
      state = const AsyncValue.loading();
      final permissions = await _service.getAllPermissions();
      state = AsyncValue.data(permissions);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Refrescar permisos (por si se agregan nuevos en el backend)
  Future<void> refresh() async {
    try {
      final permissions = await _service.getAllPermissions();
      state = AsyncValue.data(permissions);
    } catch (e) {
      print("Error refrescando permisos: $e");
    }
  }
}

// 3. El Proveedor Global
final permissionsProvider = StateNotifierProvider<PermissionsNotifier, AsyncValue<List<PermissionModel>>>((ref) {
  final service = ref.watch(permissionServiceProvider);
  return PermissionsNotifier(service);
});