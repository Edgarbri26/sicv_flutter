import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sicv_flutter/config/api_url.dart';
import '../models/type_payment_model.dart'; // Asegúrate de importar tu modelo

class TypePaymentService {
  // En Google, centralizamos las configuraciones. Esta URL debe ser tu base de API.
  final String _baseUrl = ApiUrl().url; // <-- ¡Cambia esto!

  // Headers estándar para las peticiones JSON.
  final Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    // 'Authorization': 'Bearer TU_API_KEY_SI_ES_NECESARIA',
  };

  /// READ: Obtener todos los tipos de pago
  Future<List<TypePaymentModel>> getPaymentTypes() async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/type_payment',
      ), // Asumiendo endpoint '/payment-types'
      headers: _headers,
    );
    // if (response.statusCode == 200) {
    //     // ACTUALIZACIÓN: Parseamos el Mapa y buscamos la llave 'data'
    //     final Map<String, dynamic> responseData =
    //         json.decode(response.body) as Map<String, dynamic>;
    //     final List<dynamic> roleListJson =
    //         responseData['data'] as List<dynamic>;

    //     return roleListJson
    //         .map((json) => Role.fromJson(json as Map<String, dynamic>))
    //         .toList();
    //   }
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> jsonList = responseData['data'] as List<dynamic>;
      // Mapeamos la lista de JSONs a una lista de objetos TypePaymentModel
      return jsonList.map((json) => TypePaymentModel.fromJson(json)).toList();
    } else {
      // Lanzamos una excepción para que la UI pueda manejar el error.
      throw Exception(
        'Falló al cargar los tipos de pago. Código: ${response.statusCode}',
      );
    }
  }

  /// CREATE: Crear un nuevo tipo de pago
  Future<void> createPaymentType(String name) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/type_payment'),
      headers: _headers,
      // Solo enviamos el nombre, el backend maneja el resto.
      body: json.encode({'name': name}),
    );

    if (response.statusCode == 201) {
      // 201 = Created
      // El backend debería devolver el objeto completo recién creado.
      // return TypePaymentModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Falló al crear el tipo de pago.');
    }
  }

  /// UPDATE: Actualizar un tipo de pago existente
  Future<void> updatePaymentType(int id, String newName) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/type_payment/$id'),
      headers: _headers,
      body: json.encode({'name': newName}),
    );

    if (response.statusCode == 200) {
      // return TypePaymentModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Falló al actualizar el tipo de pago.');
    }
  }

  /// DELETE: Eliminar un tipo de pago
  Future<void> deletePaymentType(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/type_payment/$id'),
      headers: _headers,
    );

    // 200 (OK) o 204 (No Content) son respuestas exitosas para DELETE.
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Falló al eliminar el tipo de pago.');
    }
    // No se retorna contenido.
  }
}
