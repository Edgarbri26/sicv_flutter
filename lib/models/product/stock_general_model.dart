/// Represents the general stock level of a product in a specific depot.
///
/// This does not account for expiration dates (lots), just the total quantity.
class StockGeneralModel {
  /// The ID of the product.
  final int productId;

  /// The ID of the depot where the stock is located.
  final int depotId;

  /// The quantity of stock available.
  final int amount;

  /// The active status of this stock record.
  final bool status;

  /// Creates a new [StockGeneralModel].
  StockGeneralModel({
    required this.productId,
    required this.depotId,
    required this.amount,
    required this.status,
  });

  /// Factory constructor to create a [StockGeneralModel] from a JSON map.
  factory StockGeneralModel.fromJson(Map<String, dynamic> json) {
    return StockGeneralModel(
      productId: json['product_id'],
      depotId: json['depot_id'],
      amount: json['amount'],
      status: json['status'],
    );
  }

  /// Helper method to create a list of [StockGeneralModel] from a JSON list.
  static List<StockGeneralModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => StockGeneralModel.fromJson(json)).toList();
  }

  /// Converts this [StockGeneralModel] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'depot_id': depotId,
      'amount': amount,
      'status': status,
    };
  }
}
