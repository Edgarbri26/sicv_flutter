// --- 1. Importa el nuevo modelo que acabas de crear ---

import 'category.dart';

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl; // La URL de la imagen
  final int stock;
  final String? sku;
  
  // --- 2. Añade el campo 'category' ---
  // No es un String, es un objeto de tipo Category
  final ProductCategory category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.stock,
    required this.category,// <-- 3. Añádelo al constructor
    this.sku,// <-- 3. Añádelo al constructor
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['product_id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['base_price'].toString()),
      imageUrl: json['image_url'],
      stock: json['stock'],
      
      // --- 4. La Magia (Llama al 'fromJson' de Category) ---
      // Le pasamos el objeto JSON anidado 'category'
      // al constructor 'Category.fromJson'.
      category: ProductCategory.fromJson(json['category']),
    );
  }
}