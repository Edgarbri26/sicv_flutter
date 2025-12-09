/// Represents a specific batch or lot of stock with an expiration date.
class StockLotModel {
  /// Unique identifier for the stock lot.
  final int stockLotId;

  /// The ID of the product in this lot.
  final int productId;

  /// The ID of the depot where this lot is stored.
  final int depotId;

  /// The expiration date of the lot.
  final DateTime expirationDate;

  /// The quantity of items in this lot.
  final int amount;

  /// The cost per unit for this specific lot.
  final double costLot;

  /// The active status of this lot.
  final bool status;

  /// Creates a new [StockLotModel].
  StockLotModel({
    required this.stockLotId,
    required this.productId,
    required this.depotId,
    required this.expirationDate,
    required this.amount,
    required this.costLot,
    required this.status,
  });

  /// Factory constructor to create a [StockLotModel] from a JSON map.
  factory StockLotModel.fromJson(Map<String, dynamic> json) {
    return StockLotModel(
      stockLotId: json['stock_lot_id'],
      productId: json['product_id'],
      depotId: json['depot_id'],
      expirationDate: DateTime.parse(json['expiration_date']),
      amount: json['amount'],
      costLot: double.parse(json['cost_lot'].toString()),
      status: json['status'],
    );
  }

  /// Helper method to create a list of [StockLotModel] from a JSON list.
  static List<StockLotModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => StockLotModel.fromJson(json)).toList();
  }

  /// Converts this [StockLotModel] instance to a JSON map.
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

  /// Returns a formatted string describing the lot's expiration and availability.
  ///
  /// Example: "Vence: 25/12/2025 (Disp: 50)"
  /// Useful for FEFO (First Expired, First Out) selection UI.
  String get displayLabel {
    final dateStr =
        "${expirationDate.day}/${expirationDate.month}/${expirationDate.year}";
    // FEFO: First Expired, First Out
    return "Vence: $dateStr (Disp: ${amount.toStringAsFixed(0)})";
  }
}
