import 'package:sicv_flutter/models/sale_item_model.dart';

class SaleModel {
  final String clientCi;
  final String userCi;
  final int typePaymentId;
  final DateTime soldAt;
  final List<SaleItemModel> saleItems;

  SaleModel({
    required this.clientCi,
    required this.userCi,
    required this.typePaymentId,
    required this.soldAt,
    required this.saleItems,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      clientCi: json['client_ci'],
      userCi: json['user_ci'],
      typePaymentId: json['type_payment_id'],
      soldAt: DateTime.parse(json['sold_at']),
      saleItems: (json['sale_items'] as List)
          .map((item) => SaleItemModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'client_ci': clientCi,
      'user_ci': userCi,
      'type_payment_id': typePaymentId,
      'sold_at': soldAt.toIso8601String(),
      'sale_items': saleItems.map((item) => item.toJson()).toList(),
    };
  }
}