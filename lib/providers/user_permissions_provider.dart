// providers/user_permissions_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sicv_flutter/models/permission_model.dart';
import 'package:sicv_flutter/providers/user_provider.dart'; // Importante para leer el usuario
import 'package:sicv_flutter/services/permission_service.dart';

// 1. LA VARIABLE GLOBAL
final userPermissionsProvider = StateNotifierProvider<UserPermissionsNotifier, Set<String>>((ref) {
  return UserPermissionsNotifier(ref);
});

// 2. LA LÓGICA
class UserPermissionsNotifier extends StateNotifier<Set<String>> {
  final Ref _ref;
  final PermissionService _permissionService = PermissionService(); // Instancia del servicio

  UserPermissionsNotifier(this._ref) : super({});

  /// Carga los permisos basados en el usuario autenticado actual.
  Future<void> loadUserPermissions() async {
    try {
      // A. Obtenemos el usuario desde el UserProvider (Single Source of Truth)
      // Usamos .read porque estamos dentro de una función asíncrona lógica
      final userAsync = _ref.read(userProvider);
      final user = userAsync.value;

      // Guard Clause: Si no hay usuario o rol, limpiamos y salimos
      if (user == null || user.rolId == null) {
        state = {}; 
        return;
      }

      // B. Llamada a la API
      final List<PermissionModel> permissionsList = await _permissionService
          .getPermissionsByRole(user.rolId!);

      print("✅ Permisos cargados para ${user.name}: ${permissionsList.length}");

      // C. Mapping: Convertimos de Objetos a Strings únicos
      final Set<String> permissionStrings = permissionsList
          .map((p) => p.name) // Asegúrate que tu modelo tenga .name, .slug o .code
          .toSet();

      // D. Actualizamos el estado
      state = permissionStrings;
      
    } catch (e) {
      print("❌ Error cargando permisos: $e");
      state = {}; // En caso de error, denegar acceso por defecto
    }
  }

  /// Limpia los permisos (útil al hacer logout)
  void clear() {
    state = {};
  }
}