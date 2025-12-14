import 'package:flutter/material.dart';
import 'package:sicv_flutter/services/remote_config_service.dart';
import 'package:sicv_flutter/services/test_service.dart';
import 'package:sicv_flutter/ui/pages/config/api_config_page.dart';
import 'package:sicv_flutter/ui/pages/login_page.dart';

class ApiCheckPage extends StatefulWidget {
  const ApiCheckPage({super.key});

  @override
  State<ApiCheckPage> createState() => _ApiCheckPageState();
}

class _ApiCheckPageState extends State<ApiCheckPage> {
  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    final TestService _service = TestService();
    final url = RemoteConfigService().apiUrl;
    debugPrint('🔍 Verificando conexión a: $url');

    try {
      // Intentamos un GET simple. Asumimos que /products o una ruta base existe.
      // Un timeout corto es clave para no hacer esperar al usuario.
      final response = await _service.test(url);
      if (response.statusCode == 200 || response.statusCode == 401) {
        // 200 OK o 401 Unauthorized significan que el servidor RESPONDE.
        debugPrint('✅ Conexión exitosa al backend.');
        _goToLogin();
      } else {
        debugPrint('⚠️ Servidor respondió con error: ${response.statusCode}');
        _goToConfig();
      }
    } catch (e) {
      debugPrint('❌ Error de conexión: $e');
      _goToConfig();
    }
  }

  void _goToLogin() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _goToConfig() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ApiConfigPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Conectando con el servidor...'),
          ],
        ),
      ),
    );
  }
}
