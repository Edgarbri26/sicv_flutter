import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sicv_flutter/config/api_url.dart';
import 'package:sicv_flutter/models/report/report_spots.dart';
import 'package:sicv_flutter/models/report/inventory_efficiency.dart';
import 'package:sicv_flutter/providers/report/client_report_provider.dart';

class ReportService {
  final String _baseUrl = ApiUrl().url; // <-- ¡Cambia esto!
  final http.Client _client;

  ReportService({http.Client? client}) : _client = client ?? http.Client();

  Future<ReportSpots> getSalesDatesStats(
    String filter, {
    DateTime? start,
    DateTime? end,
  }) async {
    try {
      // 2. Construimos los Query Parameters dinámicamente
      final Map<String, String> queryParams = {
        'filter': filter,
      };

      // Si es 'custom', añadimos las fechas en formato ISO
      if (filter == 'custom' && start != null && end != null) {
        queryParams['customStart'] = start.toIso8601String();
        queryParams['customEnd'] = end.toIso8601String();
      }

      // 3. Creamos la URI base y reemplazamos los parámetros
      // Esto maneja automáticamente los ? y & de la URL
      final uri = Uri.parse('$_baseUrl/report/sales_dates_stats')
          .replace(queryParameters: queryParams);

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

        final Map<String, dynamic> salesData =
            responseData['data'] as Map<String, dynamic>;

        return ReportSpots.fromJson(salesData);
      } else {
        throw Exception(
          'Error al cargar la lista de ventas (Código: ${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      throw Exception('Error de conexión al obtener las ventas: $e');
    }
  }

  Future<double> getTotalSales() async {
    final uri = Uri.parse('$_baseUrl/report/total_usd_sales');
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

        final double salesData = (responseData['data'] as num).toDouble();

        return salesData;
      } else {
        throw Exception(
          'Error al cargar la lista de ventas (Código: ${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      throw Exception('Error de conexión al obtener las ventas.');
    }
  }

  Future<double> getTotalPurchases() async {
    final uri = Uri.parse(
      // '$_baseUrl/report/total_usd_purchases?filter=$filter',
      '$_baseUrl/report/total_usd_purchases',
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

        final double purchasesData = (responseData['data'] as num).toDouble();

        return purchasesData;
      } else {
        throw Exception(
          'Error al cargar la lista de compras (Código: ${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      throw Exception('Error de conexión al obtener las compras.');
    }
  }

  Future<List<InventoryEfficiencyPoint>> getInventoryEfficiency(
    String filter, {
    DateTime? start,
    DateTime? end,
  }) async {
    try {
      final Map<String, dynamic> params = {'period': filter};

      if (filter == 'custom' && start != null && end != null) {
        params['customStart'] = start.toIso8601String();
        params['customEnd'] = end.toIso8601String();
      }

      final uri = Uri.parse('$_baseUrl/report/inventory_efficiency')
          .replace(queryParameters: params);

      final response = await _client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> dataList = responseData['data'] as List<dynamic>;

        return dataList
            .map((item) => InventoryEfficiencyPoint.fromJson(item))
            .toList();
      } else {
        throw Exception('Error loading inventory efficiency (Code: ${response.statusCode})');
      }
    } catch (e) {
      debugPrint(e.toString());
      throw Exception('Error connecting to efficiency service: $e');
    }
  }

  Future<double> getInventoryValue() async {
    final uri = Uri.parse('$_baseUrl/report/inventory_value');
    try {
      final response = await _client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            json.decode(response.body) as Map<String, dynamic>;
        final Map<String, dynamic> data =
            responseData['data'] as Map<String, dynamic>;
        // El backend devuelve { "total_value_usd": 1234.50, "currency": "USD" }
        return (data['total_value_usd'] as num).toDouble();
      } else {
        throw Exception('Error al cargar valor de inventario');
      }
    } catch (e) {
      debugPrint(e.toString());
      throw Exception('Error de conexión al obtener valor de inventario.');
    }
  }

  // 2. Obtener Total de Items Físicos
  Future<int> getTotalItems() async {
    final uri = Uri.parse('$_baseUrl/report/total_inventory_items');
    try {
      final response = await _client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            json.decode(response.body) as Map<String, dynamic>;
        final Map<String, dynamic> data =
            responseData['data'] as Map<String, dynamic>;
        // El backend devuelve { "total_items": 150 }
        return data['total_items'] as int;
      } else {
        throw Exception('Error al cargar conteo de items');
      }
    } catch (e) {
      debugPrint(e.toString());
      throw Exception('Error de conexión al obtener conteo de items.');
    }
  }

  Future<List<Map<String, dynamic>>> getInventoryByCategory() async {
    final uri = Uri.parse('$_baseUrl/report/inventory_by_category');
    try {
      final response = await _client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            json.decode(response.body) as Map<String, dynamic>;
        // El backend devuelve data: [{ name: "...", value: 100, percentage: 10, color: "#..." }]
        final List<dynamic> data = responseData['data'] as List<dynamic>;

        // Retornamos la lista de mapas casteada correctamente
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        throw Exception('Error al cargar inventario por categoría');
      }
    } catch (e) {
      debugPrint(e.toString());
      throw Exception('Error de conexión al obtener categorías.');
    }
  }

  Future<List<Map<String, dynamic>>> getTopSellingProducts(
    String filter, {
    DateTime? start,
    DateTime? end,
  }) async {
    try {
      // Construimos los params
      final Map<String, dynamic> params = {'period': filter};

      if (filter == 'custom' && start != null && end != null) {
        params['customStart'] = start.toIso8601String();
        params['customEnd'] = end.toIso8601String();
      }

      // Uri seguro
      final uri = Uri.parse('$_baseUrl/report/top_selling_products')
          .replace(queryParameters: params);

      final response = await _client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            json.decode(response.body) as Map<String, dynamic>;
        
        final List<dynamic> data = responseData['data'] as List<dynamic>;
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        throw Exception('Error loading top products (Code: ${response.statusCode})');
      }
    } catch (e) {
      debugPrint(e.toString());
      throw Exception('Error connecting to top products service: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getEmployeePerformance(
    String filter,
  ) async {
    // El backend espera ?period=month (o week, year)
    final uri = Uri.parse(
      '$_baseUrl/report/employee_performance?period=$filter',
    );

    try {
      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer ...', // Si usas token
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            json.decode(response.body) as Map<String, dynamic>;

        // Estructura esperada: { data: [{ name, sales_count, total_profit, color }, ...] }
        final List<dynamic> data = responseData['data'] as List<dynamic>;

        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        throw Exception(
          'Error al cargar rendimiento (Code: ${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint("Error en getEmployeePerformance: $e");
      throw Exception('Error de conexión al obtener datos de empleados.');
    }
  }

  Future<List<ClientCorrelationPoint>> fetchClientCorrelationFM({
    String period = 'year',
  }) async {
    // Asumo que _baseUrl es accesible aquí
    final uri = Uri.parse(
      '$_baseUrl/report/client_correlation_fm?period=$period',
    );

    try {
      final response = await _client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // El backend devuelve: { "data": [...] }
        final List<dynamic> dataList = jsonResponse['data'] ?? [];

        // Mapea la lista de JSON a la lista de modelos de Dart
        return dataList
            .map((json) => ClientCorrelationPoint.fromJson(json))
            .toList();
      } else {
        throw Exception(
          'Error ${response.statusCode}: No se pudo cargar la data de correlación.',
        );
      }
    } catch (e) {
      debugPrint('Error en ReportService.fetchClientCorrelationFM: $e');
      throw Exception('Fallo la conexión o el procesamiento de datos.');
    }
  }
}
