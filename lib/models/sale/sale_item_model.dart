/// Represents an individual item within a sale transaction.
class SaleItemModel {
  /// Unique identifier for the sale item (nullable if new).
  final int? id; // sale_item_id (Nulo al crear)

  /// The ID of the sale transaction this item belongs to.
  final int? saleId; // sale_id (Nulo al crear)

  /// The ID of the product sold.
  final int productId; // product_id

  /// The ID of the depot from which the product was taken.
  final int depotId; // depot_id

  /// The cost per unit of the item at the moment of sale.
  final double unitCost; // unit_cost

  /// The quantity of items sold.
  int amount; // amount

  /// The active status of this item record.
  final bool status; // status

  /// The name of the product (for display purposes).
  final String? productName; // nombre del producto

  /// Optional batch information (if applicable).
  final int? stockLotId; // stock_lot_id

  /// Additional fields for extended functionality
  final String? depotName;

  /// Information about expiration, if applicable.
  final String? expirationInfo;

  /// Creates a new [SaleItemModel].
  SaleItemModel({
    this.id,
    this.saleId,
    required this.productId,
    required this.depotId,
    required this.unitCost,
    required this.amount,
    this.status = true, // Por defecto activo al crear
    this.productName,
    this.stockLotId,
    this.depotName,
    this.expirationInfo,
  });

  /// Factory constructor to create a [SaleItemModel] from a JSON map.
  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      id: json['sale_item_id'],
      saleId: json['sale_id'],
      productId: json['product_id'],
      depotId: json['depot_id'],
      // El backend manda "999.99" (String), así que usamos tryParse para seguridad
      unitCost: double.tryParse(json['unit_cost'].toString()) ?? 0.0,
      amount: json['amount'],
      status: json['status'] ?? true,
      productName: json['product'], // Asumiendo que el backend envía este campo
      stockLotId: json['stock_lot_id'],
    );
  }

  /// Converts this [SaleItemModel] instance to a JSON map.
  ///
  /// Used when sending sale data to the backend. Note that IDs are omitted as they are generated server-side.
  Map<String, dynamic> toJson() {
    return {
      // Nota: No enviamos 'sale_item_id' ni 'sale_id' porque el backend los genera
      'product_id': productId,
      'depot_id': depotId,
      'unit_cost': unitCost,
      'amount': amount,
      'status': status,
      'stock_lot_id': stockLotId,
    };
  }
}
