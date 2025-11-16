import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sicv_flutter/config/api_url.dart';
import 'package:sicv_flutter/models/product.dart';

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
}