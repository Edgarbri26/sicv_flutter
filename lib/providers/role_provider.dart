// providers/role_providers.dart
// (Este es un nuevo archivo para organizar tus providers)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/models/role_model.dart';
import 'package:sicv_flutter/models/permission_model.dart';
import 'package:sicv_flutter/services/role_service.dart';
import 'package:sicv_flutter/services/permission_service.dart';

// --- PROVEEDORES DE SERVICIO ---

/// Proveedor para la instancia de RoleService
final roleServiceProvider = Provider<RoleService>((ref) {
  return RoleService();
});

/// Proveedor para la instancia de PermissionService
final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

// --- PROVEEDORES DE DATOS (FutureProviders) ---

/// Obtiene y cachea la lista de TODOS los roles.
/// `.autoDispose` limpia el caché si no se usa, ahorrando memoria.
final allRolesProvider = FutureProvider.autoDispose<List<RoleModel>>((ref) async {
  // Observa el servicio
  final roleService = ref.watch(roleServiceProvider);
  // Llama al método y devuelve el futuro
  return roleService.getAllRoles();
});

/// Obtiene y cachea la lista de TODOS los permisos disponibles.
final allPermissionsProvider = FutureProvider.autoDispose<List<Permission>>((ref) async {
  final permissionService = ref.watch(permissionServiceProvider);
  return permissionService.getAllPermissions();
});