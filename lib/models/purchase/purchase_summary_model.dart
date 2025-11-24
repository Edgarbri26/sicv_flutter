// lib/models/purchase/purchase_summary_model.dart

class PurchaseSummaryModel {
  final int? purchaseId;
  final int providerId;
  final double totalUsd;
  final double totalVes;
  final DateTime boughtAt;
  final String status;
  
  // Nombres planos para mostrar
  final String providerName;
  final String userName;
  final String paymentMethodName;

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