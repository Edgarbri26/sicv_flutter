/// Represents a data point for an inventory efficiency chart (e.g., Scatter Plot).
///
/// Maps the quantity sold vs. total profit for a specific item/category.
class InventoryEfficiencyPoint {
  /// The name of the item or category (Label).
  final String name;

  /// The quantity of units sold (X-axis).
  final double quantitySold; // Eje X

  /// The total profit generated (Y-axis).
  final double totalProfit; // Eje Y

  /// Creates a new [InventoryEfficiencyPoint].
  InventoryEfficiencyPoint({
    required this.name,
    required this.quantitySold,
    required this.totalProfit,
  });

  /// Factory constructor to create an [InventoryEfficiencyPoint] from a JSON map.
  factory InventoryEfficiencyPoint.fromJson(Map<String, dynamic> json) {
    return InventoryEfficiencyPoint(
      name: json['name'] ?? 'Desconocido',
      // Aseguramos que se convierta a double incluso si viene como int
      quantitySold: (json['quantity_sold'] as num?)?.toDouble() ?? 0.0,
      totalProfit: (json['total_profit'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
