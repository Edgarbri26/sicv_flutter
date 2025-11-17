import 'package:sicv_flutter/models/purchase_general_item_model.dart';
import 'package:sicv_flutter/models/purchase_lots_item_model.dart';

class PurchaseModel {
  final int providerId;
  final String userCi;
  final int typePaymentId;
  final String status;
  final List<PurchaseGeneralItemModel>? purchaseItems;
  final List<PurchaseLotsItemModel>? purchaseLots;

  PurchaseModel({
    required this.providerId,
    required this.userCi,
    required this.typePaymentId,
    required this.status,
    this.purchaseItems,
    this.purchaseLots,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {

    final List<dynamic> generalItemsJson = json['purchase_items'] ?? []; 
    final List<dynamic> lotItemsJson = json['purchase_lots'] ?? [];

    return PurchaseModel(
      providerId: json['provider_id'],
      userCi: json['user_ci'],
      typePaymentId: json['type_payment_id'],
      status: json['status'],
      purchaseItems: generalItemsJson
          .map((item) => PurchaseGeneralItemModel.fromJson(item))
          .toList(),
            
      purchaseLots: lotItemsJson
          .map((item) => PurchaseLotsItemModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider_id': providerId,
      'user_ci': userCi,
      'type_payment_id': typePaymentId,
      'status': status,
      'purchase_items': purchaseItems?.map((item) => item.toJson()).toList(),
      'purchase_lots': purchaseLots?.map((item) => item.toJson()).toList(),
    };
  }
}