import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sicv_flutter/models/provider_model.dart';
import 'package:sicv_flutter/services/provider_service.dart';

final providersServiceProvider = Provider<ProviderService>((ref) {
  return ProviderService();
});


class ProvidersNotifier extends StateNotifier<AsyncValue<List<ProviderModel>>> {
  final ProviderService _service;

  ProvidersNotifier(this._service) : super(const AsyncValue.loading()) {
    loadProviders();
  }

  Future<void> loadProviders() async {
    try {
      state = const AsyncValue.loading();
      final providers = await _service.getAll();
      state = AsyncValue.data(providers);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    try {
      final providers = await _service.getAll();
      state = AsyncValue.data(providers);
    } catch (e) {
      print("Error refrescando proveedores: $e");
    }
  }

  Future<void> createProvider({
    required String name,
    required String located,
  }) async {
    await _service.create({
      'name': name,
      'located': located,
    });
    await refresh();
  }

  Future<void> updateProvider({
    required int id,
    required String newName,
    required String located,
  }) async {
    await _service.update(id, {
      'name': newName,
      'located': located,
    });
    await refresh();
  }

  Future<void> deleteProvider({
    required int id,
  }) async {
    await _service.delete(id);
    await refresh();
  }

  Future<void> deactivateProvider({
    required int id,
  }) async {
    await _service.deactivate(id);
    await refresh();
  }

  Future<void> activateProvider({
    required int id,
  }) async {
    await _service.activate(id);
    await refresh();
  }
}

final providersProvider = StateNotifierProvider<ProvidersNotifier, AsyncValue<List<ProviderModel>>>((ref) {
  final service = ref.watch(providersServiceProvider);
  return ProvidersNotifier(service);
});