import 'dart:convert';
import 'dart:io'; // Para SocketException
import 'package:http/http.dart' as http;
import 'package:sicv_flutter/config/api_url.dart';
import 'package:sicv_flutter/core/exceptions/backend_exception.dart';
import 'package:sicv_flutter/models/sale/sale_model.dart';
import 'package:sicv_flutter/models/sale/sale_summary_model.dart';

class SaleService {
  final String _baseUrl = ApiUrl().url;
  final Map<String, String> _headers = {'Content-Type': 'application/json'};

  /// 1. OBTENER TODAS LAS VENTAS (Resumido)
  Future<List<SaleSummaryModel>> getAll() async {
    final url = Uri.parse('$_baseUrl/sale');

    try {
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> jsonList = responseBody['data'];

        return jsonList.map((json) => SaleSummaryModel.fromJson(json)).toList();
      } else {
        _handleError(response);
        throw Exception("Unreachable");
      }
    } on BackendException {
      rethrow;
    } catch (e) {
      throw _customException(e);
    }
  }

  /// 2. OBTENER UNA VENTA POR ID (Detallado)
  Future<SaleModel> getById(int id) async {
    final url = Uri.parse('$_baseUrl/sale/$id');

    try {
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final Map<String, dynamic> saleJson = responseBody['data'];

        return SaleModel.fromJson(saleJson);
      } else {
        _handleError(response);
        throw Exception("Unreachable");
      }
    } on BackendException {
      rethrow;
    } catch (e) {
      throw _customException(e);
    }
  }

  /// 3. CREAR NUEVA VENTA
  Future<SaleModel> createSale(SaleModel sale) async {
    final url = Uri.parse('$_baseUrl/sale');

    // Construcción del JSON directa y limpia
    final Map<String, dynamic> bodyMap = {
      'client_ci': sale.clientCi,
      'user_ci': sale.userCi,             // <--- Directo, sin trucos
      'type_payment_id': sale.typePaymentId, // <--- Directo, sin trucos
      'sale_items': sale.saleItems.map((item) => item.toJson()).toList(),
    };

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode(bodyMap),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        return SaleModel.fromJson(responseBody['data']);
      } else {
        _handleError(response);
        throw Exception("Unreachable");
      }
    } on BackendException {
      rethrow;
    } catch (e) {
      throw _customException(e);
    }
  }

  // ==========================================
  // HELPERS PRIVADOS
  // ==========================================

  void _handleError(http.Response response) {
    String errorMessage;
    try {
      final Map<String, dynamic> errorBody = json.decode(response.body);
      errorMessage = errorBody['message'] ?? 
                     errorBody['error'] ?? 
                     errorBody['detail'] ?? 
                     'Error desconocido del servidor';
    } catch (e) {
      errorMessage = 'Error inesperado (${response.statusCode})';
    }
    throw BackendException(errorMessage);
  }

  Exception _customException(dynamic error) {
    if (error is SocketException) {
      return BackendException('Sin conexión a internet. Verifique su red.');
    }
    if (error is BackendException) return error;
    
    return BackendException('Ocurrió un error inesperado: $error');
  }
}