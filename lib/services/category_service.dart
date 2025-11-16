// lib/services/category_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart'; // Asegúrate de importar tu modelo
import 'package:sicv_flutter/config/api_url.dart';

class CategoryService {
  // Cambia esto por la URL base de tu API
  // final String _baseUrl = "http://localhost:3000/api";
  final String _baseUrl = ApiUrl().url; // <-- ¡Cambia esto!


  // --- OBTENER TODAS LAS CATEGORÍAS ---
  Future<List<CategoryModel>> getCategories() async {
    final url = Uri.parse('$_baseUrl/category');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        
        // 1. Decodifica el OBJETO completo
        final Map<String, dynamic> responseBody = json.decode(response.body);

        // 2. Extrae la LISTA de la propiedad 'data'
        final List<dynamic> jsonList = responseBody['data'];

        // 3. Mapea la lista
        return jsonList.map((json) => CategoryModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar las categorías (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // --- OBTENER UNA CATEGORÍA POR ID ---
  Future<CategoryModel> getCategoryById(int id) async {
    final url = Uri.parse('$_baseUrl/category/$id');

    try {
      final response = await http.get(url); // Añadir headers si es necesario

      if (response.statusCode == 200) {
        // Asumiendo que tu API devuelve el objeto { "data": {cat} }
        // como en tu ejemplo de la compra
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final Map<String, dynamic> categoryJson = responseBody['data'];
        
        return CategoryModel.fromJson(categoryJson);
      } else {
        throw Exception('Error al cargar la categoría (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // --- CREAR UNA NUEVA CATEGORÍA ---
  Future<CategoryModel> createCategory(String name, String description) async {
    final url = Uri.parse('$_baseUrl/category');

    // Crea el cuerpo de la petición
    final body = json.encode({
      'name': name,
      'description': description,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) { // 201 = Creado
        // Asumiendo que la API devuelve la nueva categoría creada
        return CategoryModel.fromJson(json.decode(response.body)['data']);
      } else {
        throw Exception('Error al crear la categoría (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<CategoryModel> updateCategory(
    int id,
    String name,
    String description,
    bool status,
  ) async {
    final url = Uri.parse('$_baseUrl/category/$id');

    final body = json.encode({
      'name': name,
      'description': description,
      'status': status,
    });

    try {
      // --- ¡CAMBIO JUSTO AQUÍ! ---
      // Cambiamos http.put por http.patch
      final response = await http.patch( 
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) { 
        return CategoryModel.fromJson(json.decode(response.body)['data']);
      } else {
        throw Exception('Error al actualizar la categoría (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> deactivateCategory(int id) async {
    final url = Uri.parse('$_baseUrl/category/$id/deactivate');

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Error al desactivar la categoría (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  
  Future<void> activateCategory(int id) async {
    final url = Uri.parse('$_baseUrl/category/$id/activate');

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Error al activar la categoría (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<CategoryModel>> getAllCategories() async {
    final url = Uri.parse('$_baseUrl/category');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> jsonList = responseBody['data'];

        return jsonList.map((json) => CategoryModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}