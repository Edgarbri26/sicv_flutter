import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sicv_flutter/models/user/user_model.dart';
import 'package:sicv_flutter/services/user_service.dart';

// 1. Servicio
final userServiceManagementProvider = Provider<UserService>((ref) => UserService());

// 2. Notifier
class UserManagementNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  final UserService _service;

  UserManagementNotifier(this._service) : super(const AsyncValue.loading()) {
    loadUsers();
  }

  // Cargar lista de usuarios
  Future<void> loadUsers() async {
    try {
      state = const AsyncValue.loading();
      final users = await _service.getAll();
      state = AsyncValue.data(users);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Crear usuario
  Future<void> createUser(String ci, String name, String pass, int roleId) async {
    await _service.create(userCi: ci, name: name, password: pass, roleId: roleId);
    await loadUsers(); // Recargamos para ver al nuevo usuario
  }

  // --- AQUÍ ESTABA LO QUE TE FALTABA ---
  // Actualizar usuario (Nombre, Rol o Estado)
  Future<void> updateUser(String ci, {String? name, int? roleId, bool? status}) async {
    // Llama al servicio pasando los parámetros opcionales
    await _service.update(ci, name: name, roleId: roleId, status: status);
    // Recarga la lista para reflejar los cambios en la UI
    await loadUsers();
  }

  // Eliminar usuario
  Future<void> deleteUser(String ci) async {
    await _service.delete(ci);
    // Actualización optimista (quitamos de la lista localmente para que sea rápido)
    state.whenData((users) {
      state = AsyncValue.data(users.where((u) => u.userCi != ci).toList());
    });
  }
}

// 3. Provider Global de Usuarios
final usersProvider = StateNotifierProvider<UserManagementNotifier, AsyncValue<List<UserModel>>>((ref) {
  final service = ref.watch(userServiceManagementProvider);
  return UserManagementNotifier(service);
});