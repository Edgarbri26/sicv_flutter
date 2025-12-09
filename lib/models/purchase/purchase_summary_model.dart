// lib/models/purchase/purchase_summary_model.dart

/// Represents a summary view of a purchase transaction.
///
/// Contains high-level information suitable for list views.
class PurchaseSummaryModel {
  /// Unique identifier of the purchase.
  final int? purchaseId;

  /// ID of the provider/supplier.
  final int providerId;

  /// Total amount in USD.
  final double totalUsd;

  /// Total amount in VES (Bolivars).
  final double totalVes;

  /// Date and time when the purchase was made.
  final DateTime boughtAt;

  /// Status of the purchase (e.g., "Pendiente", "Aprobado").
  final String status;

  // Nombres planos para mostrar

  /// Name of the provider.
  final String providerName;

  /// Name of the user who recorded the purchase.
  final String userName;

  /// Name of the payment method.
  final String paymentMethodName;

  /// Creates a new [PurchaseSummaryModel].
  PurchaseSummaryModel({
    required this.purchaseId,
    required this.providerId,
    required this.totalUsd,
    required this.totalVes,
    required this.boughtAt,
    required this.status,
    required this.providerName,
    required this.userName,
    required this.paymentMethodName,
  });

  /// Factory constructor to create a [PurchaseSummaryModel] from a JSON map.
  factory PurchaseSummaryModel.fromJson(Map<String, dynamic> json) {
    return PurchaseSummaryModel(
      purchaseId: json['purchase_id'],
      providerId: json['provider_id'],
      totalUsd: double.tryParse(json['total_usd'].toString()) ?? 0.0,
      totalVes: double.tryParse(json['total_ves'].toString()) ?? 0.0,
      boughtAt: DateTime.parse(json['bought_at'] ?? DateTime.now().toString()),
      status: json['status'] ?? 'Pendiente',

      // Leemos los strings planos que envía tu backend en el resumen
      providerName: json['provider']?.toString() ?? 'N/A',
      userName: json['user']?.toString() ?? 'N/A',
      paymentMethodName: json['type_payment']?.toString() ?? 'N/A',
    );
  }
}
