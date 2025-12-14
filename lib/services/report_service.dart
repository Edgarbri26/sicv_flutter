import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sicv_flutter/config/api_url.dart';
import 'package:sicv_flutter/models/purchase/purchase_summary_model.dart';
import 'package:sicv_flutter/models/report/report_spots.dart';
import 'package:sicv_flutter/models/report/inventory_efficiency.dart';
import 'package:sicv_flutter/models/sale/sale_summary_model.dart';
import 'package:sicv_flutter/providers/report/client_report_provider.dart';
import 'package:sicv_flutter/providers/report/inventory_provider.dart' show StockAlert;

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
    String period, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    
    // Construimos los parámetros query
    final Map<String, String> queryParams = {
      'period': period,
    };

    // Si es custom y tenemos fechas, las formateamos YYYY-MM-DD
    if (period == 'custom' && startDate != null && endDate != null) {
      final dateFormat = DateFormat('yyyy-MM-dd');
      queryParams['startDate'] = dateFormat.format(startDate);
      queryParams['endDate'] = dateFormat.format(endDate);
    }

    final uri = Uri.parse('$_baseUrl/report/employee_performance')
        .replace(queryParameters: queryParams);

    try {
      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer ...', 
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            json.decode(response.body) as Map<String, dynamic>;

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
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    
    // 1. Construcción de Query Params
    final Map<String, String> queryParams = {
      'period': period,
    };

    // Si es personalizado, agregamos las fechas formateadas
    if (period == 'custom' && startDate != null && endDate != null) {
      final dateFormat = DateFormat('yyyy-MM-dd');
      queryParams['startDate'] = dateFormat.format(startDate);
      queryParams['endDate'] = dateFormat.format(endDate);
    }

    final uri = Uri.parse('$_baseUrl/report/client_correlation_fm')
        .replace(queryParameters: queryParams);

    try {
      final response = await _client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> dataList = jsonResponse['data'] ?? [];

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

  // --- HISTORIAL DE VENTAS ---
  Future<List<SaleSummaryModel>> getSalesByRange(
    String period, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // 1. Agregamos el periodo al mapa de parámetros
    final Map<String, String> queryParams = {
      'period': period,
    };

    // 2. Si hay fechas específicas (para 'custom'), las formateamos
    if (startDate != null && endDate != null) {
      final formatter = DateFormat('yyyy-MM-dd');
      queryParams['startDate'] = formatter.format(startDate);
      queryParams['endDate'] = formatter.format(endDate);
    }

    final uri = Uri.parse('$_baseUrl/report/sales_report_range')
        .replace(queryParameters: queryParams);

    try {
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        return data.map((e) => SaleSummaryModel.fromJson(e)).toList();
      } else if (response.statusCode == 404) {
        return []; 
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al obtener historial de ventas: $e');
    }
  }

  // --- HISTORIAL DE COMPRAS ---
  Future<List<PurchaseSummaryModel>> getPurchasesByRange(
    String period, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // 1. Agregamos el periodo
    final Map<String, String> queryParams = {
      'period': period,
    };

    // 2. Agregamos fechas si existen
    if (startDate != null && endDate != null) {
      final formatter = DateFormat('yyyy-MM-dd');
      queryParams['startDate'] = formatter.format(startDate);
      queryParams['endDate'] = formatter.format(endDate);
    }

    final uri = Uri.parse('$_baseUrl/report/purchases_report_range')
        .replace(queryParameters: queryParams);

    try {
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        return data.map((e) => PurchaseSummaryModel.fromJson(e)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al obtener historial de compras: $e');
    }
  }

  Future<Map<String, dynamic>> getSupplierAnalysis(
    String period, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final Map<String, String> queryParams = {
      'period': period,
    };

    if (startDate != null && endDate != null) {
      final formatter = DateFormat('yyyy-MM-dd');
      queryParams['startDate'] = formatter.format(startDate);
      queryParams['endDate'] = formatter.format(endDate);
    }

    final uri = Uri.parse('$_baseUrl/report/provider_analysis')
        .replace(queryParameters: queryParams);

    try {
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        // Retornamos el mapa 'data' directamente
        return jsonResponse['data'] as Map<String, dynamic>;
      } else {
        throw Exception(
            'Error ${response.statusCode}: No se pudo cargar el análisis de proveedores.');
      }
    } catch (e) {
      debugPrint('Error en ReportService.getSupplierAnalysis: $e');
      throw Exception('Fallo la conexión o el procesamiento de datos.');
    }
  }

  Future<List<StockAlert>> getLowStockAlerts() async {
    final uri = Uri.parse('$_baseUrl/report/low_stock_alerts');
    
    try {
      final response = await _client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            json.decode(response.body) as Map<String, dynamic>;
        
        // Asumimos que la respuesta es { "success": true, "data": [...] }
        final List<dynamic> data = responseData['data'] as List<dynamic>;

        return data.map((json) => StockAlert.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar alertas de stock (Código: ${response.statusCode})');
      }
    } catch (e) {
      debugPrint("Error en getLowStockAlerts: $e");
      // Retornamos lista vacía en error para no romper toda la pantalla, 
      // pero podrías lanzar la excepción si prefieres.
      return []; 
    }
  }
}
