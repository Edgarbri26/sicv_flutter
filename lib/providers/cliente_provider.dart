import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sicv_flutter/models/client_model.dart';
import 'package:sicv_flutter/services/client_service.dart';

final clientProvider =
    StateNotifierProvider<ClienteProvider, AsyncValue<List<ClientModel>>>((
      ref,
    ) {
      return ClienteProvider(ClientService());
    });

class ClienteProvider extends StateNotifier<AsyncValue<List<ClientModel>>> {
  final ClientService _service;

  ClienteProvider(this._service) : super(const AsyncValue.loading()) {
    loadItems();
  }

  Future<void> loadItems() async {
    try {
      state = const AsyncValue.loading();
      final items = await _service.getAll();
      state = AsyncValue.data(items);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    try {
      final items = await _service.getAll();
      state = AsyncValue.data(items);
    } catch (e) {
      // Si falla el refresh silencioso, no cambiamos el estado actual
      debugPrint("Error refrescando clientes: $e");
    }
  }

  Future<void> create({
    required String ci,
    required String name,
    required String phone,
    required String address,
  }) async {
    await _service.create(ci: ci, name: name, phone: phone, address: address);
    await refresh();
  }

  Future<void> update({
    required String ci,
    required String name,
    required String phone,
    required String address,
    required bool status,
  }) async {
    await _service.update(
      ci,
      name: name,
      phone: phone,
      address: address,
      status: status,
    );
    await refresh();
  }

  Future<void> activate(String ci) async {
    await _service.activate(ci);
    await refresh();
  }

  Future<void> deactivate(String ci) async {
    await _service.deactivate(ci);
    await refresh();
  }

  Future<void> delete(String ci) async {
    await _service.delete(ci);
    await refresh();
  }
}
