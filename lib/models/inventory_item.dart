class InventoryItem {
  final String id;
  final String name;
  final String description;
  final int quantity;
  final double price;
  final String category;
  final DateTime lastUpdated;
  final String? imageUrl;

  InventoryItem({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.price,
    required this.category,
    required this.lastUpdated,
    this.imageUrl,
  });

  InventoryItem copyWith({
    String? id,
    String? name,
    String? description,
    int? quantity,
    double? price,
    String? category,
    DateTime? lastUpdated,
    String? imageUrl,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      category: category ?? this.category,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}