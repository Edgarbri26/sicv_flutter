import 'dart:convert';
import 'package:http/http.dart' as http;
// Asegúrate de que la ruta sea correcta y el nombre del modelo coincida
import '../models/client_model.dart';
import 'package:sicv_flutter/config/api_url.dart';


class ClientService {
  // final String _baseUrl = "http://localhost:3000/api"; // IP para emulador
    final String _baseUrl = ApiUrl().url; // <-- ¡Cambia esto!


  // --- OBTENER TODOS LOS CLIENTES ---
  Future<List<ClientModel>> getClients() async {
    final url = Uri.parse('$_baseUrl/client');
    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> jsonList = responseBody['data'];
        return jsonList.map((json) => ClientModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Error al cargar los clientes (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // --- OBTENER UN CLIENTE POR CI (ID) ---
  Future<ClientModel> getClientById(String ci) async {
    final url = Uri.parse('$_baseUrl/client/$ci');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        return ClientModel.fromJson(responseBody['data']);
      } else {
        throw Exception(
            'Error al cargar el cliente (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // --- CREAR UN NUEVO CLIENTE (Sin Email) ---
  Future<ClientModel> createClient({
    required String ci,
    required String name,
    required String phone,
    required String address,
  }) async {
    final url = Uri.parse('$_baseUrl/client');
    final body = json.encode({
      'client_ci': ci,
      'name': name,
      'phone': phone,
      'address': address,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        return ClientModel.fromJson(json.decode(response.body)['data']);
      } else {
        throw Exception(
            'Error al crear el cliente (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // --- ACTUALIZAR UN CLIENTE (Sin Email) ---
  Future<ClientModel> updateClient(
    String ci, {
    required String name,
    required String phone,
    required String address,
    required bool status,
  }) async {
    final url = Uri.parse('$_baseUrl/client/$ci');
    final body = json.encode({
      'name': name,
      'phone': phone,
      'address': address,
      'status': status,
    });

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        return ClientModel.fromJson(json.decode(response.body)['data']);
      } else {
        throw Exception(
            'Error al actualizar el cliente (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // --- ELIMINAR UN CLIENTE ---
  Future<void> deleteClient(String ci) async {
    final url = Uri.parse('$_baseUrl/client/$ci');
    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
            'Error al eliminar el cliente (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}