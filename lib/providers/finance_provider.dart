import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/models/purchase/purchase_summary_model.dart';
import 'package:sicv_flutter/models/sale/sale_summary_model.dart'; // Tu modelo de ventas (SaleSummaryModel)
import 'package:sicv_flutter/services/purchase_service.dart';
import 'package:sicv_flutter/services/sale_service.dart';
// import 'package:sicv_flutter/models/purchase_model.dart'; // (Crear este archivo luego)
// import 'package:sicv_flutter/services/purchase_service.dart'; // (Crear este archivo luego)

// ======================================================
// 1. PROVIDERS DE SERVICIOS (INYECCIÓN DE DEPENDENCIAS)
// ======================================================
// Esto permite que si cambias la lógica del servicio, no rompas la UI.
final saleServiceProvider = Provider<SaleService>((ref) {
  return SaleService();
});

// Si aún no tienes PurchaseService, comenta esto o crea un dummy
final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  return PurchaseService();
});

// ======================================================
// 2. PROVIDERS DE DATOS (LOS QUE USAS EN LA VISTA)
// ======================================================

// A. Provider de Historial de Ventas
// Usamos autoDispose para que al salir de la pantalla se limpie la memoria
final salesHistoryProvider = FutureProvider.autoDispose<List<SaleSummaryModel>>((ref) async {
  // 1. Obtenemos el servicio
  final service = ref.watch(saleServiceProvider);
  
  // 2. Llamamos a la API
  // Nota: Asegúrate de que tu SaleService.getAll() devuelva List<SaleSummaryModel>
  return await service.getAll();
});

// B. Provider de Historial de Compras
final purchasesHistoryProvider = FutureProvider.autoDispose<List<PurchaseSummaryModel>>((ref) async {
  // 1. Obtenemos el servicio
  final service = ref.watch(purchaseServiceProvider);
  
  // 2. Llamamos a la API
  return await service.getAll();
});