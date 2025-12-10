import 'package:flutter/material.dart';
import 'package:sicv_flutter/services/remote_config_service.dart';
import 'package:sicv_flutter/ui/pages/splash/api_check_page.dart';

class ApiConfigPage extends StatefulWidget {
  const ApiConfigPage({super.key});

  @override
  State<ApiConfigPage> createState() => _ApiConfigPageState();
}

class _ApiConfigPageState extends State<ApiConfigPage> {
  final _controller = TextEditingController();
  final _service = RemoteConfigService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.text = _service.apiUrl;
  }

  Future<void> _saveAndRetry() async {
    if (_controller.text.isEmpty) return;

    setState(() => _isLoading = true);

    // Guardar la nueva URL
    await _service.setCustomUrl(_controller.text.trim());

    if (mounted) {
      // Navegar de vuelta al CheckPage que reintentará la conexión
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ApiCheckPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración de Servidor')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.dns_outlined, size: 64, color: Colors.orange),
            const SizedBox(height: 24),
            const Text(
              'No se pudo conectar al servidor',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Por favor ingresa la dirección IP o URL del backend para continuar.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'URL del Backend',
                hintText: 'http://192.168.1.X:3000/api',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveAndRetry,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: const Text('Guardar y Reintentar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
