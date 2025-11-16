import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sicv_flutter/config/api_url.dart';
import 'package:sicv_flutter/models/purchase_model.dart';

class PurchaseService {
  final String _baseUrl = ApiUrl().url;

  Future<List<PurchaseModel>> getAllPurchases() async {
    final url = Uri.parse('$_baseUrl/purchase');

    try{
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> jsonList = responseBody['data'];

        return jsonList.map((json) => PurchaseModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load purchases (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<PurchaseModel> getPurchaseById(int id) async {
    final url = Uri.parse('$_baseUrl/purchase/$id');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final Map<String, dynamic> purchaseJson = responseBody['data'];

        return PurchaseModel.fromJson(purchaseJson);
      } else {
        throw Exception('Failed to load purchase (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<PurchaseModel> createPurchase(PurchaseModel purchase) async {
    final url = Uri.parse('$_baseUrl/purchase');
    final body = json.encode(purchase.toJson());

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final Map<String, dynamic> purchaseJson = responseBody['data'];

        return PurchaseModel.fromJson(purchaseJson);
      } else {
        throw Exception('Failed to create purchase (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}