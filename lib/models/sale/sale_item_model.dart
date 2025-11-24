class SaleItemModel {
  final int? id;       // sale_item_id (Nulo al crear)
  final int? saleId;   // sale_id (Nulo al crear)
  final int productId; // product_id
  final int depotId;   // depot_id
  final double unitCost; // unit_cost
  final int amount;    // amount
  final bool status;   // status
  final String? productName; // nombre del producto

  SaleItemModel({
    this.id,
    this.saleId,
    required this.productId,
    required this.depotId,
    required this.unitCost,
    required this.amount,
    this.status = true, // Por defecto activo al crear
    this.productName,
  });

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
    );
  }

  // Este mapa se usa para enviar al Backend al CREAR la venta
  Map<String, dynamic> toJson() {
    return {
      // Nota: No enviamos 'sale_item_id' ni 'sale_id' porque el backend los genera
      'product_id': productId,
      'depot_id': depotId,
      'unit_cost': unitCost,
      'amount': amount,
    };
  }
}