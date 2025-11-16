class PurchaseLotsItemModel {
  final int productId;
  final int purchaseId;
  final int depotId;
  final double unitCost;
  final int amount;
  final DateTime expirationDate;

  PurchaseLotsItemModel({
    required this.productId,
    required this.purchaseId,
    required this.depotId,
    required this.unitCost,
    required this.amount,
    required this.expirationDate,
  });

  factory PurchaseLotsItemModel.fromJson(Map<String, dynamic> json) {
    return PurchaseLotsItemModel(
      productId: json['product_id'],
      purchaseId: json['purchase_id'],
      depotId: json['depot_id'],
      unitCost: json['unit_cost'],
      amount: json['amount'],
      expirationDate: DateTime.parse(json['expiration_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'purchase_id': purchaseId,
      'depot_id': depotId,
      'unit_cost': unitCost,
      'amount': amount,
      'expiration_date': expirationDate.toIso8601String(),
    };
  }
}