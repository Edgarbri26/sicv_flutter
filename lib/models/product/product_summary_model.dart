/// Represents a concise version of a product, suitable for lists or dropdowns.
class ProductSummaryModel {
  /// Unique identifier of the product.
  final int id;

  /// Name of the product.
  final String name;

  /// Brief description of the product.
  final String description;

  /// Creates a new [ProductSummaryModel].
  ProductSummaryModel({
    required this.id,
    required this.name,
    required this.description,
  });

  /// Factory constructor to create a [ProductSummaryModel] from a JSON map.
  factory ProductSummaryModel.fromJson(Map<String, dynamic> json) {
    return ProductSummaryModel(
      id: json['product_id'],
      name: json['name'],
      description: json['description'] ?? '',
    );
  }

  /// Converts this [ProductSummaryModel] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {'product_id': id, 'name': name, 'description': description};
  }
}
