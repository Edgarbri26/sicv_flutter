import 'package:sicv_flutter/models/product/stock_general_model.dart';
import 'package:sicv_flutter/models/product/stock_lot_model.dart';
import '../category_model.dart';

/// Represents a product in the inventory system.
///
/// Contains detailed information about a product, including pricing,
/// stock levels (general and stratified by lots), and categorization.
class ProductModel {
  /// Unique identifier for the product.
  final int id;

  /// The name of the product.
  final String name;

  /// A detailed description of the product.
  final String description;

  /// The category to which the product belongs.
  final CategoryModel category;

  /// The base price of the product (cost or reference price).
  final double price;

  /// The selling price of the product in Bolivianos (or main currency).
  final double priceBs;

  /// The minimum stock level before an alert is triggered.
  final int minStock;

  /// Indicates if the product is perishable (has expiration date).
  final bool perishable;

  /// The active status of the product.
  final bool status;

  /// URL to the product image.
  final String? imageUrl;

  /// The total aggregated stock quantity across all depots.
  final int totalStock;

  /// List of stock quantities per depot.
  final List<StockGeneralModel> stockGenerals;

  /// List of specific stock lots (batches) with expiration dates.
  final List<StockLotModel> stockLots;

  /// The Stock Keeping Unit (SKU) code.
  final String? sku;

  /// Temporary quantity placeholder (e.g., for cart selection).
  ///
  /// Note: Ideally should be final if using copyWith exclusively, but left mutable for legacy compatibility.
  int quantity;

  /// Creates a new [ProductModel].
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

  /// Creates a copy of this [ProductModel] with the given fields replaced with the new values.
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
    List<StockLotModel>? stockLots,
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

  /// Factory constructor to create a [ProductModel] from a JSON map.
  ///
  /// Handles parsing of nested objects ([CategoryModel], [StockGeneralModel], [StockLotModel])
  /// and ensures type safety for numeric fields.
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      stockGenerals: json['stock_generals'] != null
          ? StockGeneralModel.fromJsonList(json['stock_generals'])
          : [],
      stockLots: json['stock_lots'] != null
          ? StockLotModel.fromJsonList(json['stock_lots'])
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

  /// Converts this [ProductModel] instance to a JSON map.
  ///
  /// Includes serialization of nested objects.
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
