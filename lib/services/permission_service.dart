import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sicv_flutter/config/api_url.dart';
import 'package:sicv_flutter/models/permission_model.dart';

class PermissionService {
  final String _baseUrl = ApiUrl().url;
  final http.Client _client;

  // Constructor que permite inyección de cliente (útil para tests) o usa uno por defecto
  PermissionService({http.Client? client}) : _client = client ?? http.Client();

  /// 1. Obtiene la lista MAESTRA de todos los permisos disponibles en la base de datos.
  /// Se usa en RoleEditView para mostrar el listado en el diálogo "Agregar Permiso".
  Future<List<PermissionModel>> getAllPermissions() async {
    // Asegúrate de que esta ruta coincida con tu backend (ej: /permission o /permissions)
    final uri = Uri.parse('$_baseUrl/permission'); 

    try {
      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer ...', // Si tu endpoint requiere token
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> list = responseData['data'];
        
        return list.map((json) => PermissionModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar lista de permisos (Código: ${response.statusCode})');
      }
    } catch (e) {
      print('Error getAllPermissions: $e');
      // Re-lanzamos el error para que el Provider (AsyncValue) lo capture y muestre en UI
      throw Exception('Error de conexión al obtener permisos.');
    }
  }

  /// 2. Obtiene los permisos asignados a un role específico.
  /// Se usa al hacer Login para saber qué puede hacer el usuario actual.
  Future<List<PermissionModel>> getPermissionsByRole(int roleId) async {
    final uri = Uri.parse('$_baseUrl/role/$roleId/permissions');

    try {
      final response = await _client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> list = responseData['data'];
        
        return list.map((json) => PermissionModel.fromJson(json)).toList();
      } else {
        // Si falla este (ej: role sin permisos), devolvemos lista vacía para no bloquear el login
        print('Advertencia: No se pudieron cargar permisos del role $roleId (${response.statusCode})');
        return [];
      }
    } catch (e) {
      print('Error getPermissionsByRole: $e');
      return [];
    }
  }
}