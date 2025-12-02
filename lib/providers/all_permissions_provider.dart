import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/models/permission_model.dart';
import 'package:sicv_flutter/services/permission_service.dart';

// Reutilizamos el servicio. Si ya tienes un provider del servicio en otro lado, puedes importarlo.
// Si no, esta definición local está bien.
final permissionServiceProvider = Provider<PermissionService>((ref) => PermissionService());

/// Provider que obtiene la LISTA MAESTRA de todos los permisos disponibles en la BD.
/// Se usa en la pantalla de Editar Roles para saber qué permisos se pueden asignar.
final allPermissionsProvider = FutureProvider.autoDispose<List<PermissionModel>>((ref) async {
  final service = ref.watch(permissionServiceProvider);
  return service.getAllPermissions();
});