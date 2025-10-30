import 'package:flutter/material.dart';
import 'package:sicv_flutter/ui/widgets/atomic/text_field_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/button_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';
import 'package:sicv_flutter/ui/screen/config/categories_screen.dart';

class SkuScreen extends StatefulWidget {
  const SkuScreen({super.key});

  @override
  _SkuScreenState createState() => _SkuScreenState();
}

class _SkuScreenState extends State<SkuScreen> {
  bool _skuAutomatico = true;
  final TextEditingController _prefixController = TextEditingController();

  @override
  void dispose() {
    _prefixController.dispose();
    super.dispose();
  }

  String _exampleSku() {
    final prefix = _prefixController.text.trim();
    final base = DateTime.now().millisecondsSinceEpoch
        .remainder(10000)
        .toString()
        .padLeft(4, '0');
    if (!_skuAutomatico) return 'N/A';
    if (prefix.isEmpty) return 'SKU-$base';
    return '${prefix.endsWith('-') ? prefix : '$prefix-'}$base';
  }

  @override
  Widget build(BuildContext context) {
    final example = _exampleSku();

    return Scaffold(
      appBar: const AppBarApp(title: 'Códigos y SKU', iconColor: Colors.purple),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: const Text('Generar SKU automático'),
                    subtitle: const Text(
                      'Crear un SKU único al guardar un producto nuevo',
                    ),
                    secondary: const Icon(Icons.qr_code_scanner),
                    value: _skuAutomatico,
                    onChanged: (bool value) =>
                        setState(() => _skuAutomatico = value),
                    contentPadding: EdgeInsets.zero,
                  ),

                  const Divider(),

                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                    child: TextFieldApp(
                      controller: _prefixController,
                      labelText: 'Prefijo por Defecto (Opcional)',
                      prefixIcon: Icons.text_fields,
                      enabled: _skuAutomatico,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.qr_code, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Ejemplo de SKU:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 12),
                      Chip(
                        label: Text(
                          example,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  ListTile(
                    leading: const Icon(Icons.category_outlined),
                    title: const Text('Gestionar Prefijos por Categoría'),
                    subtitle: const Text(
                      'Asignar prefijos diferentes por categoría (p.ej. "ELEC-")',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    contentPadding: EdgeInsets.zero,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CategoriesScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          PrimaryButtonApp(
            text: 'Guardar cambios',
            icon: Icons.save,
            onPressed: () {
              final prefix = _prefixController.text.trim();
              debugPrint(
                'Guardar: skuAutomatico=$_skuAutomatico, prefix=$prefix',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuración guardada')),
              );
            },
          ),
        ],
      ),
    );
  }
}
