import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/depot/depot_model.dart'; // Asegúrate de que la ruta sea correcta
import 'package:sicv_flutter/config/api_url.dart';


class DepotService {
  // final String _baseUrl = "http://localhost:3000/api"; // IP para emulador
    final String _baseUrl = ApiUrl().url; // <-- ¡Cambia esto!


  // --- OBTENER TODOS LOS ALMACENES ---
  Future<List<DepotModel>> getDepots() async {
    final url = Uri.parse('$_baseUrl/depot'); // o /depots
    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> jsonList = responseBody['data'];
        return jsonList.map((json) => DepotModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Error al cargar los almacenes (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // --- OBTENER UN ALMACÉN POR ID ---
  Future<DepotModel> getDepotById(int id) async {
    final url = Uri.parse('$_baseUrl/depot/$id'); // o /depots/$id
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        return DepotModel.fromJson(responseBody['data']);
      } else {
        throw Exception(
            'Error al cargar el almacén (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // --- CREAR UN NUEVO ALMACÉN ---
  Future<DepotModel> createDepot({
    required String name,
    required String location,
  }) async {
    final url = Uri.parse('$_baseUrl/depot'); // o /depots
    final body = json.encode({
      'name': name,
      'location': location,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        return DepotModel.fromJson(json.decode(response.body)['data']);
      } else {
        throw Exception(
            'Error al crear el almacén (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // --- ACTUALIZAR UN ALMACÉN (usando PATCH) ---
  Future<DepotModel> updateDepot(
    int id, {
    required String name,
    required String location,
    required bool status,
  }) async {
    final url = Uri.parse('$_baseUrl/depot/$id'); // o /depots/$id
    final body = json.encode({
      'name': name,
      'location': location,
      'status': status,
    });

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        return DepotModel.fromJson(json.decode(response.body)['data']);
      } else {
        throw Exception(
            'Error al actualizar el almacén (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // --- ELIMINAR UN ALMACÉN ---
  Future<void> deleteDepot(int id) async {
    final url = Uri.parse('$_baseUrl/depot/$id'); // o /depots/$id
    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
            'Error al eliminar el almacén (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> deactivateDepot(int id) async {
    final url = Uri.parse('$_baseUrl/depot/$id/deactivate');

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Error al desactivar el almacén (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  
  Future<void> activateDepot(int id) async {
    final url = Uri.parse('$_baseUrl/depot/$id/activate');

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Error al activar el almacén (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}