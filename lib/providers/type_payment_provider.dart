import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sicv_flutter/models/type_payment_model.dart';
import 'package:sicv_flutter/services/type_payment_service.dart';

// 1. Proveedor del Servicio (Para que sea testear y desacoplar)
final typePaymentServiceProvider = Provider<TypePaymentService>((ref) {
  return TypePaymentService();
});

class TypePaymentNotifier
    extends StateNotifier<AsyncValue<List<TypePaymentModel>>> {
  final TypePaymentService _service;

  TypePaymentNotifier(this._service) : super(const AsyncValue.loading()) {
    loadTypePayments();
  }

  Future<void> loadTypePayments() async {
    try {
      state = const AsyncValue.loading();
      final typePayments = await _service.getAll();
      state = AsyncValue.data(typePayments);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    try {
      final typePayments = await _service.getAll();
      state = AsyncValue.data(typePayments);
    } catch (e) {
      debugPrint("Error refrescando tipos de pago: $e");
    }
  }

  Future<void> createTypePayment({required String name}) async {
    await _service.create(name);
  }

  Future<void> updateTypePayment({
    required int id,
    required String newName,
  }) async {
    await _service.update(id, newName);
  }

  Future<void> deleteTypePayment({required int id}) async {
    await _service.delete(id);
  }

  Future<void> deactivateTypePayment({required int id}) async {
    await _service.deactivate(id);
  }

  Future<void> activateTypePayment({required int id}) async {
    await _service.activate(id);
  }
}

final typePaymentProvider =
    StateNotifierProvider<
      TypePaymentNotifier,
      AsyncValue<List<TypePaymentModel>>
    >((ref) {
      final service = ref.watch(typePaymentServiceProvider);
      return TypePaymentNotifier(service);
    });
