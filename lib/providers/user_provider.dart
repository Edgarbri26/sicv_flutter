// providers/user_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sicv_flutter/models/user/user_model.dart';
import 'package:sicv_flutter/services/auth_service.dart';
import 'package:sicv_flutter/providers/user_permissions_provider.dart'; // Necesario para encadenar la carga

// 1. Provider del Servicio
final userServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// 2. El Notifier
class UserNotifier extends StateNotifier<AsyncValue<UserModel>> {
  final AuthService _service;
  final Ref _ref; // Necesitamos esto para comunicarnos con otros providers

  // Inyectamos el servicio y el Ref
  UserNotifier(this._service, this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    await loadUser();
  }

  /// Carga el usuario de persistencia y luego sus permisos
  Future<void> loadUser() async {
    try {
      final user = await _service.getLoggedInUser();

      if (user != null) {
        state = AsyncValue.data(user);
        
        // 🔥 ENCADENAMIENTO CLAVE:
        // Ya tenemos usuario, ahora cargamos sus permisos
        await _ref.read(userPermissionsProvider.notifier).loadUserPermissions();
      } else {
        // No hay usuario logueado
        // state = const AsyncValue.data(null); // Opcional según tu manejo de nulls
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      state = const AsyncValue.loading();
      
      // 1. Llamada a API de Login
      final success = await _service.login(username, password);

      if (success) {
        // 2. Si es exitoso, recargamos el usuario (esto actualiza 'state')
        await loadUser();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      await _service.logout();
      
      // Limpieza total
      state = const AsyncValue.loading();
      _ref.read(userPermissionsProvider.notifier).clear(); // Limpiamos permisos
      
      return true;
    } catch (e) {
      print("Error al cerrar sesión: $e");
      return false;
    }
  }
}

// 3. El Provider Global
final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<UserModel>>((ref) {
  final service = ref.watch(userServiceProvider);
  // Pasamos 'ref' al constructor
  return UserNotifier(service, ref);
});