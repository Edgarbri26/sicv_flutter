/// Represents an individual item within a purchase.
///
/// Can be a general stock item or a specific lot with an expiration date.
class PurchaseItemModel {
  /// Unique identifier for the item (either general or lot ID).
  final int? id; // ID del item (general o lote)
  /// The ID of the product.
  final int productId;

  /// The ID of the depot where the item is stored.
  final int depotId;

  /// The cost per unit of the item.
  final double unitCost;

  /// The quantity of items purchased.
  final int amount;

  /// The expiration date (if applicable). Null for general stock.
  final DateTime? expirationDate; // NULL para generales, CON FECHA para lotes

  // Nombres para mostrar (Display)
  /// The name of the product.
  final String productName;

  /// The name of the depot.
  final String depotName;

  /// Creates a new [PurchaseItemModel].
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

  /// Factory constructor to create a [PurchaseItemModel] from a JSON map.
  ///
  /// Extracts product and depot names from nested objects or flat strings if available.
  factory PurchaseItemModel.fromJson(Map<String, dynamic> json) {
    // Lógica para extraer nombres
    String pName = 'N/A';
    if (json['product'] is String) {
      pName = json['product'];
    } else if (json['product_name'] != null) {
      pName = json['product_name']['name'];
    }

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

  /// Converts this [PurchaseItemModel] instance to a JSON map.
  ///
  /// Useful for sending purchase details to the backend.
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
