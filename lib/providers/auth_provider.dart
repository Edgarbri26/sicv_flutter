import 'package:flutter_riverpod/legacy.dart';
import 'package:sicv_flutter/models/user/user_model.dart';
import 'package:sicv_flutter/services/auth_service.dart';

class AuthState {
  final UserModel? user;
  final Map<String, dynamic>? fullRole; // Aquí guardaremos el rol completo traído del API
  final bool isLoading;

  AuthState({this.user, this.fullRole, this.isLoading = true});
}

// 2. El Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService();

  AuthNotifier() : super(AuthState()) {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // A. Recuperamos lo básico de SharedPreferences (Solo ID)
    final user = await _authService.getLoggedInUser();

    if (user != null) {
      // B. Estado intermedio: Tenemos usuario, pero falta el rol completo
      state = AuthState(user: user, isLoading: true);

      // C. LLAMADA AL API: Usamos el ID para buscar el rol completo
      final roleData = await _authService.fetchFullRole(user.rolId);

      // D. Estado final: Usuario + Rol completo
      state = AuthState(user: user, fullRole: roleData, isLoading: false);
    } else {
      state = AuthState(user: null, isLoading: false);
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});