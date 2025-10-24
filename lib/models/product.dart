// lib/models/product.dart

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl; // La URL de la imagen
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['product_id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['base_price'].toString()),
      imageUrl: json['image_url'],
      stock: json['stock'],
    );
  }
}