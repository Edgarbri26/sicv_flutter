import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sicv_flutter/models/user/user_model.dart';
import 'package:sicv_flutter/services/auth_service.dart';

final userServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class UserNotifier extends StateNotifier<AsyncValue<UserModel>> {
  final AuthService _service;

  UserNotifier(this._service) : super(const AsyncValue.loading()) {
    loadUser();
  }

  Future<void> loadUser() async {
    try {
      state = const AsyncValue.loading();
      final user = await _service.getLoggedInUser();
      state = AsyncValue.data(user!);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    try {
      final user = await _service.getLoggedInUser();
      state = AsyncValue.data(user!);
    } catch (e) {
      print("Error refrescando usuario: $e");
    }
  }

  Future<bool> logout() async {
    try {
      await _service.logout();
      state = const AsyncValue.loading();
      return true;
    } catch (e) {
      print("Error al cerrar sesión: $e");
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    final success = await _service.login(username, password);
    if (success) {
      await loadUser();
    }
    return success;
  }
}

final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<UserModel>>((ref) {
  final service = ref.watch(userServiceProvider);
  return UserNotifier(service);
});


