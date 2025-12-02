// Archivo: lib/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sicv_flutter/models/user/user_model.dart';
import 'package:sicv_flutter/services/auth_service.dart';
// Importamos el provider de permisos para avisarle cuando cambie el usuario
import 'package:sicv_flutter/providers/current_user_permissions_provider.dart';

// 1. Servicio inyectado
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// 2. Notifier: Maneja el estado de la sesión (Usuario Logueado o Null)
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthService _authService;
  final Ref _ref;

  AuthNotifier(this._authService, this._ref) : super(const AsyncValue.loading()) {
    checkLoginStatus();
  }

  /// Verifica al iniciar la app si hay sesión guardada en disco
  Future<void> checkLoginStatus() async {
    try {
      final user = await _authService.getLoggedInUser();
      
      if (user != null) {
        state = AsyncValue.data(user);
        
        // 🔥 CRUCIAL: Si hay usuario, cargamos sus permisos inmediatamente
        // Esto llena el currentUserPermissionsProvider
        await _ref.read(currentUserPermissionsProvider.notifier).loadPermissions(user.rolId);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Login: Llama al servicio y si es exitoso, actualiza el estado
  Future<bool> login(String username, String password) async {
    // Ponemos estado de carga si quieres que toda la app sepa que está cargando
    // state = const AsyncValue.loading(); 
    
    try {
      final success = await _authService.login(username, password);
      
      if (success) {
        // Si el login en API fue exitoso, recargamos el usuario desde SharedPreferences
        await checkLoginStatus();
        return true;
      } else {
        // Si falló (credenciales mal), nos aseguramos que el estado sea null
        // state = const AsyncValue.data(null);
        return false;
      }
    } catch (e) {
      // state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Logout: Borra token y limpia estados
  Future<void> logout() async {
    await _authService.logout();
    state = const AsyncValue.data(null);
    // Limpiamos los permisos de la memoria
    _ref.read(currentUserPermissionsProvider.notifier).clear();
  }
}

// 3. Provider Global (ESTA ES LA VARIABLE QUE TE FALTA)
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService, ref);
});