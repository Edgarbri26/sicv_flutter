import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sicv_flutter/config/api_url.dart';
import 'package:sicv_flutter/models/sale_model.dart';

class SaleService {
  final String _baseUrl = ApiUrl().url;

  Future<List<SaleModel>> getAllSales() async {
    final url = Uri.parse('$_baseUrl/sale');

    try{
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> jsonList = responseBody['data'];

        return jsonList.map((json) => SaleModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load sales (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<SaleModel> getSaleById(int id) async {
    final url = Uri.parse('$_baseUrl/sale/$id');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final Map<String, dynamic> saleJson = responseBody['data'];

        return SaleModel.fromJson(saleJson);
      } else {
        throw Exception('Failed to load sale (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<SaleModel> createSale(SaleModel sale) async {
    final url = Uri.parse('$_baseUrl/sale');
    final body = json.encode(sale.toJson());

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final Map<String, dynamic> saleJson = responseBody['data'];

        return SaleModel.fromJson(saleJson);
      } else {
        throw Exception('Failed to create sale (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}