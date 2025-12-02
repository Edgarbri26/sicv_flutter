import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sicv_flutter/config/app_permissions.dart';
import 'package:sicv_flutter/services/permission_service.dart';

// Servicio inyectado
final permissionServiceProvider = Provider<PermissionService>(
  (ref) => PermissionService(),
);

// Notifier: El estado es un Set<String> con los CÓDIGOS de permisos (ej: 'CREATE_USER', 'EDIT_PRODUCT')
class CurrentUserPermissionsNotifier extends StateNotifier<Set<String>> {
  final PermissionService _service;

  CurrentUserPermissionsNotifier(this._service) : super({});

  Future<void> loadPermissions(int roleId) async {
    try {
      final permissions = await _service.getPermissionsByRole(roleId);

      // Mapeamos a un Set de Strings (asumiendo que PermissionModel tiene un campo 'name' o 'code')
      // Usar Set hace que la búsqueda sea O(1) -> Instantánea
      final permissionCodes = permissions.map((p) => p.code).toSet();

      state = permissionCodes;
      print("✅ Permisos cargados: ${state.length}");
    } catch (e) {
      print("❌ Error cargando permisos: $e");
      state = {};
    }
  }

  void clear() {
    state = {};
  }

  /// Helper para verificar en la UI
  bool can(String permissionCode) {
    return state.contains(permissionCode) ||
        state.contains(AppPermissions.allPermissions);
  }
}

// Provider Global
final currentUserPermissionsProvider =
    StateNotifierProvider<CurrentUserPermissionsNotifier, Set<String>>((ref) {
      final service = ref.watch(permissionServiceProvider);
      return CurrentUserPermissionsNotifier(service);
    });
