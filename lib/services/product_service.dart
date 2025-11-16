import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sicv_flutter/config/api_url.dart';
import 'package:sicv_flutter/models/product_model.dart';
import 'dart:typed_data';

class ProductService {
  final String _baseUrl = ApiUrl().url;

  Future<List<ProductModel>> getAll() async {
    final url = Uri.parse('$_baseUrl/product');

    try{
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> jsonList = responseBody['data'];

        return jsonList.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<bool> createProduct({
    required String name,
    required String sku,
    required String description,
    required int categoryId,
    required double price,
    required Uint8List? imageUrl,
    required int minStock,
    required bool isPerishable
  }) async {
    final url = Uri.parse('$_baseUrl/product');

    try {
      final response = await http.post(url, headers: {
        'Content-Type': 'application/json',
      }, body: json.encode({
        'name': name,
        'sku': sku,
        'description': description,
        'category_id': categoryId,
        'base_price': price,
        'image_url': imageUrl,
        'min_stock': minStock,
        'perishable': isPerishable
      }));
      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to create product (Código: ${response.statusCode})');
      }
    } catch(e){
      throw Exception('Error de conexión: $e');
    }
  }
}