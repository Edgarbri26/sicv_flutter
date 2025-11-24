import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sicv_flutter/core/base/services_base.dart';
import '../models/provider_model.dart'; // Asegúrate de que la ruta sea correcta
import '../config/api_url.dart';

class ProviderService implements ServicesInterface<ProviderModel> {
  final String _baseUrl = ApiUrl().url; // IP para emulador

  // --- OBTENER TODOS LOS PROVEEDORES ---
  @override
  Future<List<ProviderModel>> getAll() async {
    final url = Uri.parse('$_baseUrl/provider'); // o /providers
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> jsonList = responseBody['data'];
        return jsonList.map((json) => ProviderModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'Error al cargar los proveedores (Código: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  @override
  Future<ProviderModel> getById(int id) async {
    final url = Uri.parse('$_baseUrl/provider/$id'); // o /providers/$id
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        return ProviderModel.fromJson(responseBody['data']);
      } else {
        throw Exception(
          'Error al cargar el proveedor (Código: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  @override
  Future<ProviderModel> create(Map<String, dynamic> map) async {
    final url = Uri.parse('$_baseUrl/provider'); // o /providers
    final body = json.encode({'name': map['name'], 'located': map['located']});

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Intentamos parsear el objeto retornado por la API
        try {
          final Map<String, dynamic> bodyMap = json.decode(response.body);
          final data = bodyMap['data'] ?? bodyMap['provider'] ?? bodyMap;
          if (data is Map<String, dynamic>) {
            return ProviderModel.fromJson(data);
          }
        } catch (_) {
          // Ignoramos parse errors y hacemos fallback
        }

        // Fallback: si la API no retorna el recurso, recargamos y buscamos por nombre
        final all = await getAll();
        return all.firstWhere((p) => p.name == map['name']);
      } else {
        throw Exception(
          'Error al crear el proveedor (Código: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  @override
  Future<ProviderModel> update(int id, Map<String, dynamic> map) async {
    final url = Uri.parse('$_baseUrl/provider/${id}'); // o /providers/$id
    final body = json.encode({'name': map['name'], 'located': map['located']});

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
          'Error al actualizar el proveedor (Código: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  @override
  Future<void> delete(int id) async {
    final url = Uri.parse('$_baseUrl/provider/$id'); // o /providers/$id
    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Error al eliminar el proveedor (Código: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  @override
  Future<void> deactivate(int id) async {
    final url = Uri.parse(
      '$_baseUrl/provider/$id/deactivate',
    ); // o /providers/$id
    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Error al desactivar el proveedor (Código: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  @override
  Future<void> activate(int id) async {
    final url = Uri.parse('$_baseUrl/provider/$id/activate');

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Error al activar el proveedor (Código: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
