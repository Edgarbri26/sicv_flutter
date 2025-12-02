import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sicv_flutter/config/api_url.dart';
import 'package:sicv_flutter/models/report/report_spots.dart';
import 'package:sicv_flutter/models/report/inventory_efficiency.dart';

class ReportService {
  final String _baseUrl = ApiUrl().url; // <-- ¡Cambia esto!
  final http.Client _client;

  ReportService({http.Client? client}) : _client = client ?? http.Client();

  Future<ReportSpots> getSalesDatesStats(String filter) async {
    final uri = Uri.parse('$_baseUrl/report/sales_dates_stats?filter=$filter');
    try {
      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer TU_TOKEN_JWT',
        },
      );

      if (response.statusCode == 200) {
        // ACTUALIZACIÓN: Parseamos el Mapa y buscamos la llave 'data'
        final Map<String, dynamic> responseData =
            json.decode(response.body) as Map<String, dynamic>;

        final Map<String, dynamic> salesData =
            responseData['data'] as Map<String, dynamic>;

        return ReportSpots.fromJson(salesData);
      } else {
        throw Exception(
          'Error al cargar la lista de ventas (Código: ${response.statusCode})',
        );
      }
    } catch (e) {
      print(e.toString());
      throw Exception('Error de conexión al obtener las ventas.');
    }
  }

  Future<double> getTotalSales(String filter) async {
    final uri = Uri.parse('$_baseUrl/report/total_usd_sales?filter=$filter');
    try {
      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer TU_TOKEN_JWT',
        },
      );

      if (response.statusCode == 200) {
        // ACTUALIZACIÓN: Parseamos el Mapa y buscamos la llave 'data'
        final Map<String, dynamic> responseData =
            json.decode(response.body) as Map<String, dynamic>;

        final Map<String, dynamic> salesData =
            responseData['data'] as Map<String, dynamic>;

        print(salesData);
        return salesData['total'] as double;
      } else {
        throw Exception(
          'Error al cargar la lista de ventas (Código: ${response.statusCode})',
        );
      }
    } catch (e) {
      print(e.toString());
      throw Exception('Error de conexión al obtener las ventas.');
    }
  }

  Future<double> getTotalPurchases(String filter) async {
    final uri = Uri.parse(
      '$_baseUrl/report/total_usd_purchases?filter=$filter',
    );
    try {
      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer TU_TOKEN_JWT',
        },
      );

      if (response.statusCode == 200) {
        // ACTUALIZACIÓN: Parseamos el Mapa y buscamos la llave 'data'
        final Map<String, dynamic> responseData =
            json.decode(response.body) as Map<String, dynamic>;

        final Map<String, dynamic> purchasesData =
            responseData['data'] as Map<String, dynamic>;

        print(purchasesData);
        return purchasesData['total'] as double;
      } else {
        throw Exception(
          'Error al cargar la lista de compras (Código: ${response.statusCode})',
        );
      }
    } catch (e) {
      print(e.toString());
      throw Exception('Error de conexión al obtener las compras.');
    }
  }

  Future<List<InventoryEfficiencyPoint>> getInventoryEfficiency(String filter) async {
    final uri = Uri.parse('$_baseUrl/report/inventory_efficiency?period=$filter'); // Ojo: tu backend espera query param 'period', no 'filter' según tu código de backend anterior, si es 'filter' cámbialo aquí.
    try {
      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer TU_TOKEN_JWT',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            json.decode(response.body) as Map<String, dynamic>;

        final List<dynamic> dataList = responseData['data'] as List<dynamic>;

        return dataList
            .map((item) => InventoryEfficiencyPoint.fromJson(item))
            .toList();
      } else {
        throw Exception(
          'Error al cargar eficiencia de inventario (Código: ${response.statusCode})',
        );
      }
    } catch (e) {
      print(e.toString());
      throw Exception('Error de conexión al obtener eficiencia.');
    }
  }

  Future<double> getInventoryValue() async {
    final uri = Uri.parse('$_baseUrl/report/inventory_value');
    try {
      final response = await _client.get(uri, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body) as Map<String, dynamic>;
        final Map<String, dynamic> data = responseData['data'] as Map<String, dynamic>;
        // El backend devuelve { "total_value_usd": 1234.50, "currency": "USD" }
        return (data['total_value_usd'] as num).toDouble();
      } else {
        throw Exception('Error al cargar valor de inventario');
      }
    } catch (e) {
      print(e.toString());
      throw Exception('Error de conexión al obtener valor de inventario.');
    }
  }

  // 2. Obtener Total de Items Físicos
  Future<int> getTotalItems() async {
    final uri = Uri.parse('$_baseUrl/report/total_inventory_items');
    try {
      final response = await _client.get(uri, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body) as Map<String, dynamic>;
        final Map<String, dynamic> data = responseData['data'] as Map<String, dynamic>;
        // El backend devuelve { "total_items": 150 }
        return data['total_items'] as int;
      } else {
        throw Exception('Error al cargar conteo de items');
      }
    } catch (e) {
      print(e.toString());
      throw Exception('Error de conexión al obtener conteo de items.');
    }
  }
}
