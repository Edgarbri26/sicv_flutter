import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sicv_flutter/config/api_url.dart';
import 'package:sicv_flutter/models/user/user_model.dart';

class UserService {
  final String _baseUrl = ApiUrl().url;
  final http.Client _client = http.Client();

  // --- OBTENER TODOS LOS USUARIOS ---
  Future<List<UserModel>> getAll() async {
    final uri = Uri.parse('$_baseUrl/user');
    try {
      final response = await _client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> list = responseData['data'];
        return list.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar usuarios: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // --- CREAR USUARIO ---
  Future<void> create({
    required String userCi,
    required String name,
    required String password,
    required int roleId,
    required bool status,
  }) async {
    final uri = Uri.parse('$_baseUrl/user');
    try {
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_ci': userCi,
          'name': name,
          'password': password,
          'role_id': roleId,
          'status': status,
        }),
      );

      if (response.statusCode != 201) {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Error al crear usuario');
      }
    } catch (e) {
      rethrow;
    }
  }

  // --- ACTUALIZAR role O DATOS ---
  Future<void> update(String userCi, {String? name, int? roleId, bool? status}) async {
    final uri = Uri.parse('$_baseUrl/user/$userCi');
    
    final Map<String, dynamic> body = {};
    if (name != null) body['name'] = name;
    if (roleId != null) body['role_id'] = roleId;
    if (status != null) body['status'] = status;

    try {
      final response = await _client.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar usuario');
      }
    } catch (e) {
      rethrow;
    }
  }

  // --- ELIMINAR (DESACTIVAR) USUARIO ---
  Future<void> delete(String userCi) async {
    final url = Uri.parse('$_baseUrl/user/$userCi/deactivate');

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Error al desactivar la categoría (Código: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}