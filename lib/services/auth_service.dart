import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sicv_flutter/config/api_url.dart';
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
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_ci': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final Map<String, dynamic>? data = responseData['data'];

        if (data != null) {
          final String? token = data['token'];
          final Map<String, dynamic>? userJson = data['user'];
          print(userJson);

          if (token != null && userJson != null) {
            await _saveToken(token);
            await _saveUserData(userJson);
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error login: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userDataKey);
  }

  Future<UserModel?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJsonString = prefs.getString(_userDataKey);
    if (userJsonString == null) return null;
    return UserModel.fromJson(json.decode(userJsonString));
  }

  // --- Helpers Privados ---
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _saveUserData(Map<String, dynamic> userJson) async {
    final prefs = await SharedPreferences.getInstance();
    // Aseguramos que el JSON tenga el formato correcto para el modelo
    final userModel = UserModel.fromJson(userJson);
    print(userModel.toJson());
    await prefs.setString(_userDataKey, json.encode(userModel.toJson()));
  }
}
