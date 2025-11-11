// --- 1. Importa el nuevo modelo que acabas de crear ---

import 'category_model.dart';

class Product {
  final int id;
  final String name;
  final String description;
  final CategoryModel category;
  final double price;
  final double priceBs;
  final int minStock;
  final bool perishable;
  final bool status;
  final String? imageUrl; // La URL de la imagen
  final int? stock;
  final List<dynamic> stockGenerals;
  final List<dynamic> stockLots;
  final String? sku;
  int? quantity;
  
  Product({
    required this.priceBs,
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.minStock,
    required this.perishable,
    required this.status,
    this.imageUrl,
    required this.stock,
    required this.stockGenerals,
    required this.stockLots,    
    required this.category, // <-- 3. Añádelo al constructor
    this.sku, // <-- 3. Añádelo al constructor
    this.quantity,
  }) {
    quantity = 1;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      stockGenerals: json['stock_generals'],
      stockLots: json['stock_lots'],
      priceBs: double.parse(json['price_bs'].toString()),
      minStock: json['min_stock'],
      perishable: json['perishable'],
      status: json['status'],
      id: json['product_id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['base_price'].toString()),
      imageUrl: json['image_url'],
      stock: json['stock'],
      quantity: json['quantity'],
      // --- 4. La Magia (Llama al 'fromJson' de Category) ---
      // Le pasamos el objeto JSON anidado 'category'
      // al constructor 'Category.fromJson'.
      category: CategoryModel.fromJson(json['category']),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'product_id': id,
      'name': name,
      'description': description,
      'base_price': price,
      'image_url': imageUrl,
      'stock': stock,
      'quantity': quantity,
      'category': category.toJson(),
    };
  }
}


// "product_id": 9,
//             "name": "Baterías AAA (Paquete 4)",
//             "description": "Baterías alcalinas AAA, paquete de 4.",
//             "base_price": "3.50",
//             "image_url": null,
//             "min_stock": 30,
//             "perishable": true,
//             "status": true,
//             "category": {
//                 "category_id": 4,
//                 "name": "Consumibles",
//                 "description": "Suministros que se agotan con el uso, como tinta, papel y baterías.",
//                 "status": true,
//                 "createdAt": "2025-11-11T04:16:58.477Z",
//                 "updatedAt": "2025-11-11T04:16:58.477Z"
//             },
//             "stock_generals": [],
//             "stock_lots": [
//                 {
//                     "stock_lot_id": 1,
//                     "product_id": 9,
//                     "expiration_date": "2027-10-01T00:00:00.000Z",
//                     "amount": 150,
//                     "cost_lot": "2.80",
//                     "status": true,
//                 },
//                 {
//                     "stock_lot_id": 2,
//                     "product_id": 9,
//                     "depot_id": 1,
//                     "expiration_date": "2028-03-01T00:00:00.000Z",
//                     "amount": 100,
//                     "cost_lot": "2.90",
//                     "status": true,
//                     "createdAt": "2025-11-11T04:16:58.571Z",
//                     "updatedAt": "2025-11-11T04:16:58.571Z"
//                 },
//                 {
//                     "stock_lot_id": 3,
//                     "product_id": 9,
//                     "depot_id": 3,
//                     "expiration_date": "2027-10-01T00:00:00.000Z",
//                     "amount": 80,
//                     "cost_lot": "2.80",
//                     "status": true,
//                     "createdAt": "2025-11-11T04:16:58.571Z",
//                     "updatedAt": "2025-11-11T04:16:58.571Z"
//                 }
//             ],
//             "price_bs": 815.66
//         },