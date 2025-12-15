/// Represents a specific batch or lot of stock with an expiration date.
class StockLotModel {
  /// Unique identifier composed by backend (e.g., "LOT-2") for UI keys.
  final String uid;

  final int stockLotId;
  final int productId;
  final int depotId;
  final String depotName; // Ya viene directo del backend
  final DateTime expirationDate;
  final int amount;
  final double costLot;
  final bool status;

  StockLotModel({
    required this.uid,
    required this.stockLotId,
    required this.productId,
    required this.depotId,
    required this.depotName,
    required this.expirationDate,
    required this.amount,
    required this.costLot,
    required this.status,
  });

  factory StockLotModel.fromJson(Map<String, dynamic> json) {
    return StockLotModel(
      uid: json['uid'] ?? '', // El ID único para tu Dropdown
      stockLotId: json['stock_lot_id'],
      productId: json['product_id'],
      depotId: json['depot_id'],
      // Ya no necesitamos IFs, el backend garantiza este campo
      depotName: json['depot_name'] ?? 'Depósito Desconocido',
      expirationDate: DateTime.parse(json['expiration_date']),
      amount: json['amount'],
      // Manejo seguro de números (int o double)
      costLot: double.parse(json['cost_lot'].toString()),
      status: json['status'],
    );
  }

  static List<StockLotModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => StockLotModel.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'stock_lot_id': stockLotId,
      'product_id': productId,
      'depot_id': depotId,
      'depot_name': depotName,
      'expiration_date': expirationDate.toIso8601String(),
      'amount': amount,
      'cost_lot': costLot,
      'status': status,
    };
  }

  /// Helper para mostrar en la UI (Vencimiento + Stock)
  String get displayLabel {
    final dateStr =
        "${expirationDate.day}/${expirationDate.month}/${expirationDate.year}";
    return "Vence: $dateStr (Disp: ${amount.toStringAsFixed(0)})";
  }
}