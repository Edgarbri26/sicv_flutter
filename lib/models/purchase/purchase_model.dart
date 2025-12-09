// lib/models/purchase/purchase_model.dart

import 'package:sicv_flutter/models/purchase/purchase_summary_model.dart';
import 'package:sicv_flutter/models/purchase/purchase_item_model.dart';

/// Represents a full purchase record, including details of items bought.
///
/// Extends [PurchaseSummaryModel] to include user ID, payment details, and the list of items.
class PurchaseModel extends PurchaseSummaryModel {
  // IDs necesarios para lógica interna

  /// unique identifier (Identity Card) of the user who made the purchase.
  final String userCi;

  /// ID of the payment method used.
  final int typePaymentId;

  // Una sola lista unificada para la UI

  /// Consolidated list of items purchased (both general and lot-based).
  final List<PurchaseItemModel> items;

  /// Creates a new [PurchaseModel].
  PurchaseModel({
    required super.purchaseId,
    required super.providerId,
    required super.totalUsd,
    required super.totalVes,
    required super.boughtAt,
    required super.status,
    required super.providerName,
    required super.userName,
    required super.paymentMethodName,

    required this.userCi,
    required this.typePaymentId,
    required this.items,
  });

  // LECTURA (GET By ID)

  /// Factory constructor to create a [PurchaseModel] from a JSON map.
  ///
  /// Combines `purchase_general_items` and `purchase_lot_items` into a single [items] list
  /// for easier consumption by the UI.
  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    // 1. Convertimos la lista de generales
    final generalList =
        (json['purchase_general_items'] as List<dynamic>?)
            ?.map((i) => PurchaseItemModel.fromJson(i))
            .toList() ??
        [];

    // 2. Convertimos la lista de lotes
    final lotList =
        (json['purchase_lot_items'] as List<dynamic>?)
            ?.map((i) => PurchaseItemModel.fromJson(i))
            .toList() ??
        [];

    // 3. ¡Las unimos! Así la UI solo recorre una lista
    final allItems = [...generalList, ...lotList];

    return PurchaseModel(
      // Padre (Resumen)
      purchaseId: json['purchase_id'],
      providerId: json['provider_id'],
      totalUsd: double.tryParse(json['total_usd'].toString()) ?? 0.0,
      totalVes: double.tryParse(json['total_ves'].toString()) ?? 0.0,
      boughtAt: DateTime.parse(json['bought_at']),
      status: json['status'] ?? 'Pendiente',

      // Nombres planos (Manejo de errores por si vienen nulos)
      providerName: json['provider']?.toString() ?? 'N/A',
      userName: json['user']?.toString() ?? 'N/A',
      paymentMethodName: json['type_payment']?.toString() ?? 'N/A',

      // Hijos (Detalle)
      userCi: json['user_ci'] ?? '',
      typePaymentId: json['type_payment_id'] ?? 0,
      items: allItems,
    );
  }

  // ESCRITURA (Para crear desde el carrito)

  /// Factory method to create a [PurchaseModel] for creating a new transaction.
  ///
  /// Initializes [purchaseId] to null and sets default values for calculated fields.
  factory PurchaseModel.forCreation({
    required int providerId,
    required String userCi,
    required int typePaymentId,
    required List<PurchaseItemModel> items,
  }) {
    return PurchaseModel(
      purchaseId: null,
      providerId: providerId,
      userCi: userCi,
      typePaymentId: typePaymentId,
      totalUsd: 0, // Se calcula en backend
      totalVes: 0,
      boughtAt: DateTime.now(),
      status: 'Aprobado',

      // Placeholders visuales
      providerName: 'Proveedor...',
      userName: 'Usuario...',
      paymentMethodName: 'Pago...',

      items: items,
    );
  }
}
