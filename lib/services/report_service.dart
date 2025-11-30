import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sicv_flutter/config/api_url.dart';
import 'package:sicv_flutter/models/report/report_spots.dart';

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
}
