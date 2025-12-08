import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sicv_flutter/config/api_url.dart';
import 'package:sicv_flutter/models/product/product_model.dart';
import 'dart:typed_data';

class ProductService {
  final String _baseUrl = ApiUrl().url;

  Future<List<ProductModel>> getAll() async {
    final url = Uri.parse('$_baseUrl/product');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> jsonList = responseBody['data'];

        return jsonList.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load products (Código: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<ProductModel> getById(int id) async {
    final url = Uri.parse('$_baseUrl/product/$id');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final Map<String, dynamic> productJson = responseBody['data'];

        return ProductModel.fromJson(productJson);
      } else {
        throw Exception(
          'Failed to load product (Código: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<bool> createProduct({
    required String name,
    required String sku,
    required String description,
    required int categoryId,
    required double price,
    required Uint8List? imageUrl,
    required int minStock,
    required bool isPerishable,
  }) async {
    final url = Uri.parse('$_baseUrl/product');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'sku': sku,
          'description': description,
          'category_id': categoryId,
          'base_price': price,
          'image_url':
              imageUrl, // Nota: Asegúrate de que tu backend acepte bytes o Base64 aquí
          'min_stock': minStock,
          'perishable': isPerishable,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception(
          'Failed to create product (Código: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // --- NUEVO MÉTODO: ACTUALIZAR PRODUCTO (PATCH) ---
  Future<bool> update({
    required int id,
    required String name,
    required String sku,
    required String description,
    required int categoryId,
    required double price,
    required int minStock,
    Uint8List? imageUrl, // Los bytes de la imagen
  }) async {
    final url = Uri.parse('$_baseUrl/product/$id');

    // 1. Creamos una petición Multipart en lugar de una simple json
    final request = http.MultipartRequest('PATCH', url);

    // 2. Agregamos los campos de texto (Strings)
    request.fields['name'] = name;
    request.fields['sku'] = sku;
    request.fields['description'] = description;
    request.fields['category_id'] = categoryId
        .toString(); // Multer espera strings
    request.fields['base_price'] = price.toString();
    request.fields['min_stock'] = minStock.toString();

    // 3. Agregamos la imagen SI existe
    if (imageUrl != null) {
      // Convertimos los bytes (Uint8List) a un archivo Multipart
      final file = http.MultipartFile.fromBytes(
        'image', // El nombre del campo que espera Multer (upload.single('image'))
        imageUrl,
        filename:
            'product_update.jpg', // Nombre genérico, Multer lo renombrará o Cloudinary lo usará
        // contentType: MediaType('image', 'jpeg'), // Opcional si quieres ser estricto
      );
      request.files.add(file);
    }

    try {
      // 4. Enviamos la petición
      final streamedResponse = await request.send();

      // 5. Obtenemos la respuesta
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint("Error Backend: ${response.body}");
        throw Exception('Error al actualizar (Código: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> deactivateProduct(int id) async {
    final url = Uri.parse('$_baseUrl/product/$id/deactivate');

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Error al desactivar el producto (Código: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> activateProduct(int id) async {
    final url = Uri.parse('$_baseUrl/product/$id/activate');

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Error al activar el producto (Código: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
