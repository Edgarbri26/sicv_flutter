class ProductSummaryModel {
  final int id;
  final String name;
  final String description;

  ProductSummaryModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory ProductSummaryModel.fromJson(Map<String, dynamic> json) {
    return ProductSummaryModel(
      id: json['product_id'],
      name: json['name'],
      description: json['description'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'product_id': id,
      'name': name,
      'description': description,
    };
  }
}