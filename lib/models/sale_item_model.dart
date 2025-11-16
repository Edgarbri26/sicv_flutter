class SaleItemModel {
  final int productId;
  final int amount;
  final double unitCost;
  final int depotId;
  
  SaleItemModel({
    required this.productId,
    required this.amount,
    required this.unitCost,
    required this.depotId,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      productId: json['product_id'],
      amount: json['amount'],
      unitCost: double.parse(json['unit_cost'].toString()),
      depotId: json['depot_id'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'amount': amount,
      'unit_cost': unitCost,
      'depot_id': depotId,
    };
  }
}