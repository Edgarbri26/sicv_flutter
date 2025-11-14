import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/provider_model.dart'; // Asegúrate de que la ruta sea correcta
import '../config/api_url.dart';

class ProviderService {
  final String _baseUrl = ApiUrl().url; // IP para emulador

  // --- OBTENER TODOS LOS PROVEEDORES ---
  Future<List<ProviderModel>> getProviders() async {
    final url = Uri.parse('$_baseUrl/provider'); // o /providers
    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> jsonList = responseBody['data'];
        return jsonList.map((json) => ProviderModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Error al cargar los proveedores (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // --- OBTENER UN PROVEEDOR POR ID ---
  Future<ProviderModel> getProviderById(int id) async {
    final url = Uri.parse('$_baseUrl/provider/$id'); // o /providers/$id
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        return ProviderModel.fromJson(responseBody['data']);
      } else {
        throw Exception(
            'Error al cargar el proveedor (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // --- CREAR UN NUEVO PROVEEDOR ---
  Future<ProviderModel> createProvider({
    required String name,
    required String located,
  }) async {
    final url = Uri.parse('$_baseUrl/provider'); // o /providers
    final body = json.encode({
      'name': name,
      'located': located,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        return ProviderModel.fromJson(json.decode(response.body)['data']);
      } else {
        throw Exception(
            'Error al crear el proveedor (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // --- ACTUALIZAR UN PROVEEDOR (usando PATCH) ---
  Future<ProviderModel> updateProvider(
    int id, {
    required String name,
    required String located,
  }) async {
    final url = Uri.parse('$_baseUrl/provider/$id'); // o /providers/$id
    final body = json.encode({
      'name': name,
      'located': located,
    });

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        return ProviderModel.fromJson(json.decode(response.body)['data']);
      } else {
        throw Exception(
            'Error al actualizar el proveedor (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // --- ELIMINAR UN PROVEEDOR ---
  Future<void> deleteProvider(int id) async {
    final url = Uri.parse('$_baseUrl/provider/$id'); // o /providers/$id
    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
            'Error al eliminar el proveedor (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> deactivateProvider(int id) async {
    final url = Uri.parse('$_baseUrl/provider/$id/deactivate'); // o /providers/$id
    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
            'Error al desactivar el proveedor (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> activateProvider(int id) async {
    final url = Uri.parse('$_baseUrl/provider/$id/activate');

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Error al activar el proveedor (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}