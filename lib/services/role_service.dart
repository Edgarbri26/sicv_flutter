// services/role_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sicv_flutter/config/api_url.dart';
import 'package:sicv_flutter/models/role_model.dart'; // Asegúrate que la ruta sea correcta

class RoleService {
  final String _baseUrl = ApiUrl().url; // <-- ¡Cambia esto!
  final http.Client _client;

  RoleService({http.Client? client}) : _client = client ?? http.Client();

  /// Obtiene un rol específico por su ID.
  Future<Role> getRoleById(int id) async {
    final uri = Uri.parse('$_baseUrl/rol/$id');
    try {
      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer TU_TOKEN_JWT',
        },
      );

      if (response.statusCode == 200) {
        // ACTUALIZACIÓN: Parseamos el Mapa y buscamos la llave 'data'
        final Map<String, dynamic> responseData =
            json.decode(response.body) as Map<String, dynamic>;
        final Map<String, dynamic> roleData =
            responseData['data'] as Map<String, dynamic>;

        return Role.fromJson(roleData);
      } else {
        throw Exception(
          'Error al cargar el rol (Código: ${response.statusCode})',
        );
      }
    } catch (e) {
      print(e.toString());
      throw Exception('Error de conexión al obtener el rol.');
    }
  }

  /// Obtiene una lista de todos los roles.
  Future<List<Role>> getAllRoles() async {
    final uri = Uri.parse('$_baseUrl/rol');
    try {
      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer TU_TOKEN_JWT',
        },
      );

      if (response.statusCode == 200) {
        // ACTUALIZACIÓN: Parseamos el Mapa y buscamos la llave 'data'
        final Map<String, dynamic> responseData =
            json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> roleListJson =
            responseData['data'] as List<dynamic>;

        return roleListJson
            .map((json) => Role.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Error al cargar la lista de roles (Código: ${response.statusCode})',
        );
      }
    } catch (e) {
      print(e.toString());
      throw Exception('Error de conexión al obtener los roles.');
    }
  }

  /// Crea un nuevo rol.
  Future<void> createRole(String name, List<int> permissionIds) async {
    final uri = Uri.parse('$_baseUrl/rol');
    try {
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer TU_TOKEN_JWT',
        },
        body: json.encode({'name': name, 'permission_ids': permissionIds}),
      );

      if (response.statusCode == 201) {
        // 201 Created
        // ACTUALIZACIÓN: Asumimos que la respuesta también está envuelta
        // final Map<String, dynamic> responseData =
        //     json.decode(response.body) as Map<String, dynamic>;

        // return Role.fromJson(roleData);
      } else {
        throw Exception(
          'Error al crear el rol (Código: ${response.statusCode})',
        );
      }
    } catch (e) {
      print(e.toString());
      throw Exception('Error de conexión al crear el rol.');
    }
  }

  /// Actualiza un rol existente.
  Future<void> updateRole(
    int roleId,
    String name,
    List<int> permissionIds,
  ) async {
    final uri = Uri.parse('$_baseUrl/rol/$roleId/assign_permissions');
    try {
      final response = await _client.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer TU_TOKEN_JWT',
        },
        body: json.encode({'name': name, 'permission_ids': permissionIds}),
      );

      print(response.body);
      if (response.statusCode == 200) {
        // 200 OK
        // // ACTUALIZACIÓN: Asumimos que la respuesta también está envuelta
        // final Map<String, dynamic> responseData =
        //     json.decode(response.body) as Map<String, dynamic>;
        // final Map<String, dynamic> roleData =
        //     responseData['data'] as Map<String, dynamic>;

        // return Role.fromJson(roleData);
      } else {
        throw Exception(
          'Error al actualizar el rol (Código: ${response.statusCode})',
        );
      }
    } catch (e) {
      print(e.toString());
      throw Exception('Error de conexión al actualizar el rol.');
    }
  }

  /// Elimina un rol por su ID.
  Future<void> deleteRole(int roleId) async {
    final uri = Uri.parse('$_baseUrl/rol/$roleId');
    try {
      final response = await _client.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer TU_TOKEN_JWT',
        },
      );

      // Este método está bien, no parsea el 'body' en caso de éxito (200 o 204)
      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else {
        throw Exception(
          'Error al eliminar el rol (Código: ${response.statusCode})',
        );
      }
    } catch (e) {
      print(e.toString());
      throw Exception('Error de conexión al eliminar el rol.');
    }
  }
}
