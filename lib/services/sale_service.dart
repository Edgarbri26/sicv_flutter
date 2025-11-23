import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sicv_flutter/config/api_url.dart';
import 'package:sicv_flutter/core/exceptions/backend_exception.dart';
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
        // --- AQUÍ ESTÁ LA MAGIA ---
        
        // 1. Intentamos decodificar el error que viene del backend
        String errorMessage;
        try {
          final Map<String, dynamic> errorBody = json.decode(response.body);
          // 2. Buscamos la clave donde el backend manda el mensaje (ej: 'message', 'error', 'detail')
          errorMessage = errorBody['message'] ?? errorBody['error'] ?? 'Error desconocido del servidor';
        } catch (e) {
          // Si el backend devolvió HTML (error 500) o texto plano no JSON
          errorMessage = 'Error inesperado (${response.statusCode}): ${response.body}';
        }

        // 3. Lanzamos nuestra excepción personalizada con el mensaje limpio
        throw BackendException(errorMessage);
      }
    } on BackendException {
      // Re-lanzamos la excepción limpia tal cual
      rethrow;
    } catch (e) {
      // Capturamos cualquier otro error (conexión, timeout, etc.)
      throw Exception('No se pudo conectar con el servidor. Verifique su internet.');
    }
  }
}