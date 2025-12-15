/// Represents the general stock level of a product in a specific depot.
class StockGeneralModel {
  /// Unique identifier composed by backend (e.g., "DEP-1") for UI keys.
  final String uid;

  final int productId;
  final int depotId;
  final String depotName; // Ya viene directo del backend
  final int amount;
  final bool status;

  StockGeneralModel({
    required this.uid,
    required this.productId,
    required this.depotId,
    required this.depotName,
    required this.amount,
    required this.status,
  });

  factory StockGeneralModel.fromJson(Map<String, dynamic> json) {
    return StockGeneralModel(
      uid: json['uid'] ?? '', // El ID único para tu Dropdown
      productId: json['product_id'],
      depotId: json['depot_id'],
      // Mapeo directo y limpio
      depotName: json['depot_name'] ?? 'Depósito Desconocido',
      amount: json['amount'],
      status: json['status'],
    );
  }

  static List<StockGeneralModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => StockGeneralModel.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'product_id': productId,
      'depot_id': depotId,
      'depot_name': depotName,
      'amount': amount,
      'status': status,
    };
  }
}