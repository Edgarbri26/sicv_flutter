class PurchaseItemModel {
  final int? id;         // ID del item (general o lote)
  final int productId;
  final int depotId;
  final double unitCost;
  final int amount;
  final DateTime? expirationDate; // NULL para generales, CON FECHA para lotes
  
  // Nombres para mostrar (Display)
  final String productName;
  final String depotName;

  PurchaseItemModel({
    this.id,
    required this.productId,
    required this.depotId,
    required this.unitCost,
    required this.amount,
    this.expirationDate,
    this.productName = 'N/A',
    this.depotName = 'N/A',
  });

  factory PurchaseItemModel.fromJson(Map<String, dynamic> json) {
    // Lógica para extraer nombres
    String pName = 'N/A';
    if (json['product'] is String) {
      pName = json['product'];
    } else if (json['product_name'] != null) {pName = json['product_name']['name'];}

    String dName = 'N/A';
    if (json['depot'] is String) {
      dName = json['depot'];
    } else if (json['depot_name'] != null) {
      dName = json['depot_name']['name'];
    }

    return PurchaseItemModel(
      id: json['purchase_general_id'] ?? json['purchase_lot_id'],
      productId: json['product_id'],
      depotId: json['depot_id'],
      unitCost: double.tryParse(json['unit_cost'].toString()) ?? 0.0,
      amount: json['amount'],
      // Si viene fecha, la parseamos. Si no, es null (General)
      expirationDate: json['expiration_date'] != null 
          ? DateTime.parse(json['expiration_date']) 
          : null,
      productName: pName,
      depotName: dName,
    );
  }

  // Para enviar al backend (Crear)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {
      'product_id': productId,
      'depot_id': depotId,
      'unit_cost': unitCost,
      'amount': amount,
    };
    if (expirationDate != null) {
      map['expiration_date'] = expirationDate!.toIso8601String();
    }
    return map;
  }
}