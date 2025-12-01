import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sicv_flutter/config/api_url.dart';
import 'package:sicv_flutter/models/product/stock_lots_model.dart';

class StockLotService {
  final String _baseUrl = ApiUrl().url;

  /// Obtiene los lotes activos de un producto específico
  /// GET /api/stock_lot/product/:product_id
  Future<List<StockLotModel>> getByProduct(int productId) async {
    final url = Uri.parse('$_baseUrl/stock_lot/product/$productId');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        
        // Según tu JSON, la lista viene dentro de 'data'
        final List<dynamic> jsonList = responseBody['data'];

        return jsonList.map((json) => StockLotModel.fromJson(json)).toList();
      } else {
        // Manejo básico de errores si no es 200
        throw Exception('Failed to load stock lots (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error obteniendo lotes: $e');
    }
  }
}