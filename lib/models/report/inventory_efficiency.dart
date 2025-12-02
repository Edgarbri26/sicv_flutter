class InventoryEfficiencyPoint {
  final String name;
  final double quantitySold; // Eje X
  final double totalProfit;  // Eje Y

  InventoryEfficiencyPoint({
    required this.name,
    required this.quantitySold,
    required this.totalProfit,
  });

  factory InventoryEfficiencyPoint.fromJson(Map<String, dynamic> json) {
    return InventoryEfficiencyPoint(
      name: json['name'] ?? 'Desconocido',
      // Aseguramos que se convierta a double incluso si viene como int
      quantitySold: (json['quantity_sold'] as num?)?.toDouble() ?? 0.0,
      totalProfit: (json['total_profit'] as num?)?.toDouble() ?? 0.0,
    );
  }
}