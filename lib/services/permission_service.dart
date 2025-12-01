// services/permission_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sicv_flutter/config/api_url.dart';
import 'package:sicv_flutter/models/permission_model.dart';

class PermissionService {
  final String _baseUrl = ApiUrl().url; // <-- Usa tu URL base
  final http.Client _client;

  PermissionService({http.Client? client}) : _client = client ?? http.Client();

  /// Obtiene una lista de TODOS los permisos disponibles en el sistema.
  Future<List<PermissionModel>> getAllPermissions() async {
    final uri = Uri.parse(
      '$_baseUrl/permission',
    ); // Endpoint de todos los permisos

    try {
      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer TU_TOKEN_JWT',
        },
      );

      if (response.statusCode == 200) {
        // 1. Obtenemos el Map principal
        final Map<String, dynamic> responseData =
            json.decode(response.body) as Map<String, dynamic>;

        // 2. Extraemos la Lista de la llave 'data'
        final List<dynamic> permissionListJson =
            responseData['data'] as List<dynamic>;

        // 3. Mapeamos la lista, y aquí es donde se usa tu modelo
        return permissionListJson
            .map((json) => PermissionModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Error al cargar la lista de permisos (Código: ${response.statusCode})',
        );
      }
    } catch (e) {
      print(e.toString());
      throw Exception('Error de conexión al obtener los permisos.');
    }
  }
}
