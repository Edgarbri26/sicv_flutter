class PurchaseItemInputModel {
  final int productId;
  final int depotId;
  final int amount;
  final double unitCost;
  // 💡 Campo exclusivo: Puede ser nulo para ítems no perecederos
  final DateTime? expirationDate; 

  PurchaseItemInputModel({
    required this.productId,
    required this.depotId,
    required this.amount,
    required this.unitCost,
    this.expirationDate, // Optional
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {
      'product_id': productId,
      'depot_id': depotId,
      'amount': amount,
      'unit_cost': unitCost,
    };
    
    // 💡 SÓLO añadir la fecha si existe (para evitar enviar null al backend)
    if (expirationDate != null) {
      map['expiration_date'] = expirationDate!.toIso8601String();
    }
    return map;
  }
}