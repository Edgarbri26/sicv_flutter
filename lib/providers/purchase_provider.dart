import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sicv_flutter/models/purchase/purchase_model.dart';
import 'package:sicv_flutter/services/purchase_service.dart';

// 1. Inyección del Servicio
final purchaseServiceProvider = Provider<PurchaseService>((ref) => PurchaseService());

// 2. Notifier (Opcional, si quieres mantener una lista de compras recientes en memoria)
class PurchaseNotifier extends StateNotifier<AsyncValue<void>> {
  final PurchaseService _service;

  PurchaseNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> createPurchase(PurchaseModel purchase) async {
    state = const AsyncValue.loading();
    try {
      await _service.createPurchase(purchase);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow; // Para que la UI pueda capturar el error y mostrar el SnackBar
    }
  }
}

// 3. Provider Global
final purchaseProvider = StateNotifierProvider<PurchaseNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(purchaseServiceProvider);
  return PurchaseNotifier(service);
});