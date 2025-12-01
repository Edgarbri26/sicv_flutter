class StockLotModel { 
  final int stockLotId;
  final int productId;
  final int depotId;
  final DateTime expirationDate;
  final int amount;
  final double costLot;
  final bool status;

  StockLotModel({
    required this.stockLotId,
    required this.productId,
    required this.depotId,
    required this.expirationDate,
    required this.amount,
    required this.costLot,
    required this.status,
  });

  factory StockLotModel.fromJson(Map<String, dynamic> json ) {
    return StockLotModel(
      stockLotId: json['stock_lot_id'], 
      productId: json['product_id'], 
      depotId: json['depot_id'], 
      expirationDate: DateTime.parse(json['expiration_date']), 
      amount: json['amount'], 
      costLot: double.parse(json['cost_lot'].toString()), 
      status: json['status']);
  }

  static List<StockLotModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList 
      .map((json) => StockLotModel.fromJson(json))
      .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'stock_lot_id': stockLotId,
      'product_id': productId,
      'depot_id': depotId,
      'expiration_date': expirationDate.toIso8601String(),
      'amount': amount,
      'cost_lot': costLot,
      'status': status,
    };
  }

  String get displayLabel {
    final dateStr = "${expirationDate.day}/${expirationDate.month}/${expirationDate.year}";
    // FEFO: First Expired, First Out
    return "Vence: $dateStr (Disp: ${amount.toStringAsFixed(0)})";
  }
}