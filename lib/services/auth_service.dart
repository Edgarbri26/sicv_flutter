import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sicv_flutter/config/api_url.dart';
import 'package:sicv_flutter/models/user/user_model.dart';

class AuthService {
  final String baseUrl = ApiUrl().url;
  static const String _userDataKey = 'user_data';
  static const String _tokenKey = 'auth_token';

  // Storage seguro para "Remember Me"
  final _storage = const FlutterSecureStorage();
  static const String _keyUserCI = 'secure_user_ci';
  static const String _keyPassword = 'secure_user_password';

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
    print("User JSON String from SharedPreferences: $userJsonString");
    return UserModel.fromJson(json.decode(userJsonString));
  }

  // --- Secure Credentials Management ---

  Future<void> saveCredentials(String userCI, String password) async {
    await _storage.write(key: _keyUserCI, value: userCI);
    await _storage.write(key: _keyPassword, value: password);
  }

  Future<Map<String, String>?> getCredentials() async {
    final userCI = await _storage.read(key: _keyUserCI);
    final password = await _storage.read(key: _keyPassword);

    if (userCI != null && password != null) {
      return {'user_ci': userCI, 'password': password};
    }
    return null;
  }

  Future<void> clearCredentials() async {
    await _storage.delete(key: _keyUserCI);
    await _storage.delete(key: _keyPassword);
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
