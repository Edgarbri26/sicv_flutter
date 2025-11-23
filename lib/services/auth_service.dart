import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sicv_flutter/config/api_url.dart';
import 'dart:convert';
import 'package:sicv_flutter/models/user/user_model.dart';

class AuthService {
  final String baseUrl = ApiUrl().url;

  static const String _userDataKey = 'user_data';
  static const String _tokenKey = 'auth_token';

  Future<bool> login(String username, String password) async {
    final uri = Uri.parse('$baseUrl/auth/login');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_ci': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final Map<String, dynamic>? data = responseData['data'] as Map<String, dynamic>?;

        if (data != null) {
          final String? token = data['token'] as String?;
          final Map<String, dynamic>? userJsonMap = data['user'] as Map<String, dynamic>?;
          
          // 💡 Validación Consolidada: Si falta alguno, salimos.
          if (token != null && token.isNotEmpty && userJsonMap != null) {
            try {
              await _saveToken(token);
              await _saveUserData(userJsonMap); 
              return true;

            } catch (e) {
              // Fallo en guardar token o error en la conversión del modelo.
              print('Error al guardar datos: $e');
              return false;
            }
          }
        }

        // 💡 Si no entró al if, o falló la extracción, o faltaron datos:
        return false; 

      } else {
        // Manejar 401, 500, etc.
        return false;
      }
    } catch (e) {
      print(e.toString());
      throw Exception('Error de conexión al iniciar sesión.');
    }
  }

  Future<void> _saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> _saveUserData(Map<String, dynamic> userJson) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Asumimos que UserModel.fromJson maneja la nulidad interna si es necesario
    final userModel = UserModel.fromJson(userJson);

    String userJsonString = json.encode(userModel.toJson());
    print('Datos de usuario guardados: $userJsonString');
    await prefs.setString(_userDataKey, userJsonString);

  }

  Future<UserModel?> getLoggedInUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJsonString = prefs.getString(_userDataKey);

    if (userJsonString == null) return null;

    final Map<String, dynamic> userJson = json.decode(userJsonString);

    print( 'Datos de usuario recuperados: $userJsonString');

    return UserModel.fromJson(userJson);  
  }

  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);

    await prefs.remove(_userDataKey);

    print('Sesión cerrada. Token y datos de usuario eliminados.');
  }

  Future<Map<String, dynamic>?> fetchFullRole(int roleId) async {
  final token = await getToken();
  if (token == null) return null;

  final uri = Uri.parse('$baseUrl/rol/$roleId'); // O tu endpoint: /auth/me

  try {
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Importante enviar el token
      },
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      // Asumiendo que el backend devuelve { "data": { "id": 1, "name": "Admin", "permissions": [] } }
      return decoded['data']; 
    }
  } catch (e) {
    print("Error obteniendo rol: $e");
  }
  return null;
}
}