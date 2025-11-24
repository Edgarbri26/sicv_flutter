import 'package:sicv_flutter/models/stock_general_model.dart';
import 'package:sicv_flutter/models/stock_lots_model.dart';
import '../category_model.dart';

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
  final String? imageUrl;
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
      // Nota: Es buena práctica usar condicionales (?) por si la lista viene nula
      stockGenerals: json['stock_generals'] != null 
          ? StockGeneralModel.fromJsonList(json['stock_generals']) 
          : [],
      stockLots: json['stock_lots'] != null 
          ? StockLotsModel.fromJsonList(json['stock_lots']) 
          : [],
      priceBs: double.tryParse(json['price_bs'].toString()) ?? 0.0, // tryParse es más seguro
      minStock: json['min_stock'] ?? 0,
      perishable: json['perishable'] ?? false,
      status: json['status'] ?? false,
      id: json['product_id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: double.tryParse(json['base_price'].toString()) ?? 0.0,
      imageUrl: json['image_url'],
      totalStock: json['total_stock'] ?? 0,
      category: CategoryModel.fromJson(json['category']),
      
      // --- ¡AQUÍ FALTABA ESTA LÍNEA! ---
      sku: json['sku'], 
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
      'stock_generals': stockGenerals, // Asegúrate de que estos objetos tengan su propio toJson() si los envías
      'stock_lots': stockLots,
      'sku': sku,
      'category': category.toJson(),
    };
  }
}