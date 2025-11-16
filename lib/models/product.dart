// --- 1. Importa el nuevo modelo que acabas de crear ---
import 'package:sicv_flutter/models/stock_general_model.dart';
import 'package:sicv_flutter/models/stock_lots_model.dart';
import 'category_model.dart';

class ProductModel {
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
  final int totalStock;
  final List<StockGeneralModel> stockGenerals;
  final List<StockLotsModel> stockLots;
  final String? sku;
  int quantity;

  ProductModel({
    required this.priceBs,
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.minStock,
    required this.totalStock,
    required this.perishable,
    required this.status,
    this.imageUrl,
    required this.stockGenerals,
    required this.stockLots,
    required this.category, 
    this.sku,
    this.quantity = 0,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      stockGenerals: StockGeneralModel.fromJsonList(json['stock_generals']),
      stockLots: StockLotsModel.fromJsonList(json['stock_lots']),
      priceBs: double.parse(json['price_bs'].toString()),
      minStock: json['min_stock'],
      perishable: json['perishable'],
      status: json['status'],
      id: json['product_id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['base_price'].toString()),
      imageUrl: json['image_url'],
      totalStock: json['total_stock'],
      category: CategoryModel.fromJson(json['category']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': id,
      'name': name,
      'description': description,
      'base_price': price,
      'price_bs': priceBs,
      'image_url': imageUrl,
      'min_stock': minStock,
      'perishable': perishable,
      'status': status,
      'total_stock': totalStock,
      'stock_generals': stockGenerals,
      'stock_lots': stockLots,
      'sku': sku,
      'category': category.toJson(),
    };
  }
}


//             "product_id": 9,
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
//             ],
//             "price_bs": 815.66
//         },