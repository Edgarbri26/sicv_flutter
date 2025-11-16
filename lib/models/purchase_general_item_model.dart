class PurchaseGeneralItemModel {
  final int productId;
  final int purchaseId;
  final int depotId;
  final double unitCost;
  final int amount;

  PurchaseGeneralItemModel({
    required this.productId,
    required this.purchaseId,
    required this.depotId,
    required this.unitCost,
    required this.amount,
  });

  factory PurchaseGeneralItemModel.fromJson(Map<String, dynamic> json) {
    return PurchaseGeneralItemModel(
      productId: json['product_id'],
      purchaseId: json['purchase_id'],
      depotId: json['depot_id'],
      unitCost: json['unit_cost'],
      amount: json['amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'purchase_id': purchaseId,
      'depot_id': depotId,
      'unit_cost': unitCost,
      'amount': amount,
    };
  }
}