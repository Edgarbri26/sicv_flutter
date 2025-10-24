// lib/services/product_api_service.dart

import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb; // <-- 1. Importa 'kIsWeb'
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:sicv_flutter/models/product.dart';

class ProductApiService {
  final String _baseUrl = 'http://localhost:3000/api'; // Ajusta tu IP

  Future<void> createProduct({
    required String name,
    required String description,
    required double price,
    // ... otros campos de texto
    required XFile imageFile,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/product');
      final request = http.MultipartRequest('POST', uri);

      // Añade los campos de texto (esto no cambia)
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['base_price'] = price.toString();
      request.fields['stock'] = '10';
      request.fields['min_stock'] = '5';
      request.fields['category_id'] = '1';

      // --- 2. LÓGICA CORREGIDA PARA ADJUNTAR EL ARCHIVO ---
      http.MultipartFile file;

      if (kIsWeb) {
        // En la web, leemos los bytes del archivo
        final bytes = await imageFile.readAsBytes();
        file = http.MultipartFile.fromBytes(
          'image', // Nombre del campo
          bytes,   // El contenido del archivo
          filename: imageFile.name, // El nombre del archivo
        );
      } else {
        // En móvil o escritorio, usamos la ruta del archivo
        file = await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          filename: imageFile.name,
        );
      }
      
      request.files.add(file);
      // --- FIN DE LA LÓGICA CORREGIDA ---

      print("Enviando petición...");
      final response = await request.send();

      if (response.statusCode == 201) {
        print('Producto creado exitosamente.');
      } else {
        final responseBody = await response.stream.bytesToString();
        print('Error al crear el producto. Código: ${response.statusCode}');
        print('Respuesta del servidor: $responseBody');
      }
    } catch (e) {
      print('Ocurrió una excepción al intentar conectar con el servidor: $e');
    }
  }

  Future<List<Product>> getProducts() async {
    try {
      final uri = Uri.parse('$_baseUrl/product');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // El backend devuelve un objeto { message: '...', data: [...] }
        final jsonData = jsonDecode(response.body);
        
        // Extraemos la lista de datos del campo 'data'
        final List<dynamic> productList = jsonData['data'];
        
        // Convertimos cada item del JSON a un objeto Product
        return productList.map((json) => Product.fromJson(json)).toList();
      } else {
        // Si el servidor responde con un error
        throw Exception('Error al obtener los productos: ${response.statusCode}');
      }
    } catch (e) {
      // Si hay un error de conexión
      throw Exception('Falla de red al intentar obtener los productos: $e');
    }
  }
}