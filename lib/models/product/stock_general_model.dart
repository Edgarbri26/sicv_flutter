class StockGeneralModel {
  final int productId;
  final int depotId;
  final int amount;
  final bool status;

  StockGeneralModel({
    required this.productId,
    required this.depotId,
    required this.amount,
    required this.status,
  });

  factory StockGeneralModel.fromJson(Map<String, dynamic> json) {
    return StockGeneralModel(
      productId: json['product_id'],
      depotId: json['depot_id'],
      amount: json['amount'],
      status: json['status'],
    );
  }

  static List<StockGeneralModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => StockGeneralModel.fromJson(json))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'depot_id': depotId,
      'amount': amount,
      'status': status,
    };
  }   
}