import 'dart:convert';
import 'dart:io'; // Para SocketException
import 'package:http/http.dart' as http;
import 'package:sicv_flutter/config/api_url.dart';
import 'package:sicv_flutter/core/exceptions/backend_exception.dart';
import 'package:sicv_flutter/models/purchase/purchase_model.dart';
import 'package:sicv_flutter/models/purchase/purchase_summary_model.dart';

class PurchaseService {
  final String _baseUrl = ApiUrl().url;
  final Map<String, String> _headers = {'Content-Type': 'application/json'};

  /// 1. OBTENER TODAS LAS COMPRAS (Resumido)
  Future<List<PurchaseSummaryModel>> getAll() async {
    final url = Uri.parse('$_baseUrl/purchase');

    try {
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> jsonList = responseBody['data'];

        return jsonList.map((json) => PurchaseSummaryModel.fromJson(json)).toList();
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

  /// 2. OBTENER UNA COMPRA POR ID (Detallado)
  Future<PurchaseModel> getById(int id) async {
    final url = Uri.parse('$_baseUrl/purchase/$id');

    try {
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final Map<String, dynamic> purchaseJson = responseBody['data'];

        return PurchaseModel.fromJson(purchaseJson);
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

  /// 3. CREAR NUEVA COMPRA
  Future<PurchaseModel> createPurchase(PurchaseModel purchase) async {
    final url = Uri.parse('$_baseUrl/purchase');

    // Construimos el body. 
    // Como dijiste que el backend separa las listas, enviamos todo junto en 'purchase_items'.
    final Map<String, dynamic> bodyMap = {
      'provider_id': purchase.providerId,
      'user_ci': purchase.userCi,
      'type_payment_id': purchase.typePaymentId,
      'status': purchase.status, // Ej: "Aprobado"
      
      // Enviamos la lista unificada. 
      // El toJson de cada item decidirá si envía 'expiration_date' o no.
      'purchase_items': purchase.items.map((item) => item.toJson()).toList(),
    };

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode(bodyMap),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final Map<String, dynamic> purchaseJson = responseBody['data'];
        
        return PurchaseModel.fromJson(purchaseJson);
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