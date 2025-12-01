import 'package:sicv_flutter/models/product/stock_general_model.dart';
import 'package:sicv_flutter/models/product/stock_lots_model.dart';
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
  int quantity; // Nota: Si usas copyWith, idealmente esto debería ser final también.

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

  // ==========================================
  //  MÉTODO COPYWITH (AÑADIDO AQUÍ)
  // ==========================================
  ProductModel copyWith({
    int? id,
    String? name,
    String? description,
    CategoryModel? category,
    double? price,
    double? priceBs,
    int? minStock,
    bool? perishable,
    bool? status,
    String? imageUrl,
    int? totalStock,
    List<StockGeneralModel>? stockGenerals,
    List<StockLotsModel>? stockLots,
    String? sku,
    int? quantity,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      priceBs: priceBs ?? this.priceBs,
      minStock: minStock ?? this.minStock,
      perishable: perishable ?? this.perishable,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      totalStock: totalStock ?? this.totalStock,
      // Nota: Aquí pasamos la referencia de la lista. 
      // Si la lista es nueva, la reemplaza. Si es null, mantiene la vieja.
      stockGenerals: stockGenerals ?? this.stockGenerals,
      stockLots: stockLots ?? this.stockLots,
      sku: sku ?? this.sku,
      quantity: quantity ?? this.quantity,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      stockGenerals: json['stock_generals'] != null 
          ? StockGeneralModel.fromJsonList(json['stock_generals']) 
          : [],
      stockLots: json['stock_lots'] != null 
          ? StockLotsModel.fromJsonList(json['stock_lots']) 
          : [],
      priceBs: double.tryParse(json['price_bs'].toString()) ?? 0.0,
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
      'stock_generals': stockGenerals,
      'stock_lots': stockLots,
      'sku': sku,
      'category': category.toJson(),
    };
  }
}