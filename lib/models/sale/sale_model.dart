import 'package:sicv_flutter/models/sale/sale_summary_model.dart';
import 'package:sicv_flutter/models/sale/sale_item_model.dart';

class SaleModel extends SaleSummaryModel {
  // --- CAMPOS DE ID REALES (Ahora son parte oficial del modelo) ---
  final String userCi;
  final int typePaymentId;
  
  final List<SaleItemModel> saleItems;

  // Nombres para mostrar en la UI (Display)
  final String clientNameDetail;
  final String userNameDetail;
  final String typePaymentDetail;

  SaleModel({
    required super.saleId,
    required super.clientCi,
    required super.totalUsd,
    required super.totalVes,
    required super.soldAt,
    required super.status,
    required super.clientName,
    required super.sellerName,
    required super.paymentMethodName,
    
    required this.userCi,          // <--- Agregado
    required this.typePaymentId,   // <--- Agregado
    required this.saleItems,
    required this.clientNameDetail,
    required this.userNameDetail,
    required this.typePaymentDetail,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    final String clientStr = json['client']?.toString() ?? 'N/A';
    final String userStr = json['user']?.toString() ?? 'N/A';
    final String paymentStr = json['type_payment']?.toString() ?? 'N/A';

    return SaleModel(
      // Padre
      saleId: json['sale_id'],
      clientCi: json['client_ci'] ?? '',
      totalUsd: double.tryParse(json['total_usd'].toString()) ?? 0.0,
      totalVes: double.tryParse(json['total_ves'].toString()) ?? 0.0,
      soldAt: DateTime.parse(json['sold_at']),
      status: json['status'] ?? false,
      clientName: clientStr,
      sellerName: userStr,
      paymentMethodName: paymentStr,
      
      // --- LEEMOS LOS IDS REALES DEL JSON ---
      userCi: json['user_ci'] ?? '', 
      typePaymentId: json['type_payment_id'] ?? 0,

      // Detalles UI
      clientNameDetail: clientStr,
      userNameDetail: userStr,
      typePaymentDetail: paymentStr,
      
      saleItems: (json['sale_items'] as List<dynamic>?)
          ?.map((item) => SaleItemModel.fromJson(item))
          .toList() ?? [],
    );
  }

  // Factory para CREAR (Ahora es mucho más lógico)
  factory SaleModel.forCreation({
    required String clientCi,
    required String userCi, 
    required int typePaymentId,
    required List<SaleItemModel> items,
  }) {
    return SaleModel(
      saleId: null,
      clientCi: clientCi,
      userCi: userCi,                 // <--- Guardamos directo
      typePaymentId: typePaymentId,   // <--- Guardamos directo
      totalUsd: 0,
      totalVes: 0,
      soldAt: DateTime.now(),
      status: true,
      
      // Placeholders visuales (no afectan la lógica de guardado)
      clientName: 'Cliente...', 
      sellerName: 'Vendedor...',
      paymentMethodName: 'Pago...',
      clientNameDetail: '',
      userNameDetail: '',
      typePaymentDetail: '',
      
      saleItems: items,
    );
  }
}