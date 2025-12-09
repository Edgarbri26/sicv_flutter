/// Represents a product category in the inventory system.
class CategoryModel {
  /// Unique identifier for the category.
  final int id;

  /// The name of the category.
  final String name;

  /// The active status of the category.
  final bool status;

  /// A description of the category.
  final String description;

  /// Creates a new [CategoryModel].
  CategoryModel({
    required this.id,
    required this.name,
    required this.status,
    required this.description,
  });

  /// Factory constructor to create a [CategoryModel] from a JSON map.
  ///
  /// Mappings:
  /// - `category_id` -> [id]
  /// - `name` -> [name]
  /// - `status` -> [status]
  /// - `description` -> [description]
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['category_id'],
      name: json['name'],
      status: json['status'],
      description: json['description'],
    );
  }

  /// Converts this [CategoryModel] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'category_id': id,
      'name': name,
      'status': status,
      'description': description,
    };
  }
}
