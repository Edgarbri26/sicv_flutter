import 'package:http/http.dart' as http;

class TestService {
  Future<http.Response> test(String url) async {
    try {
      final response = await http
          .get(
            Uri.parse('$url/category'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      return response;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
