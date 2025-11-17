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
    final unitCostValue = json['unit_cost']?.toString(); 
    final amountValue = json['amount']?.toString();

    final dateString = json['expiration_date'] as String?;

    if (dateString == null) {
      throw FormatException('Fecha de vencimiento faltante o nula para el producto ${json['product_id']}.');
    }

    return PurchaseLotsItemModel(
      productId: json['product_id'],
      purchaseId: json['purchase_id'],
      depotId: json['depot_id'],
      unitCost: double.tryParse(unitCostValue ?? '0.0') ?? 0.0,
      amount: int.tryParse(amountValue ?? '0') ?? 0,
      expirationDate: DateTime.parse(dateString),
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