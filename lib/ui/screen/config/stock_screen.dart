import 'package:flutter/material.dart';
import 'package:sicv_flutter/ui/widgets/atomic/text_field_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/button_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  _StockScreenState createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  bool _alertasActivas = true;
  final TextEditingController _minController = TextEditingController(
    text: '10',
  );
  final TextEditingController _maxController = TextEditingController(
    text: '100',
  );

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final min = _minController.text.trim();
    final max = _maxController.text.trim();

    return Scaffold(
      appBar: const AppBarApp(
        title: 'Niveles de Stock',
        iconColor: Colors.black,
      ),
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
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFieldApp(
                    controller: _minController,
                    labelText: 'Stock Mínimo por Defecto',
                    prefixIcon: Icons.arrow_downward,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 12),

                  TextFieldApp(
                    controller: _maxController,
                    labelText: 'Stock Máximo por Defecto',
                    prefixIcon: Icons.arrow_upward,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Rango: ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 6),
                      Chip(label: Text('$min - $max')),
                    ],
                  ),

                  const SizedBox(height: 12),

                  const Divider(),

                  SwitchListTile(
                    title: const Text('Alertas de Inventario Bajo'),
                    subtitle: const Text(
                      'Recibir notificaciones cuando el stock esté por debajo del mínimo',
                    ),
                    secondary: const Icon(Icons.warning_amber),
                    value: _alertasActivas,
                    onChanged: (bool value) {
                      setState(() {
                        _alertasActivas = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          PrimaryButtonApp(
            text: 'Guardar configuración',
            icon: Icons.save,
            onPressed: () {
              // Validación simple
              final minVal = int.tryParse(_minController.text) ?? 0;
              final maxVal = int.tryParse(_maxController.text) ?? 0;
              if (minVal < 0 || maxVal < 0 || minVal > maxVal) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Rango inválido: revisa los valores'),
                  ),
                );
                return;
              }
              // Guardado simulado
              debugPrint(
                'Guardar stock: min=$minVal, max=$maxVal, alerts=$_alertasActivas',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configuración de stock guardada'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
