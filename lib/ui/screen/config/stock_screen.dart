import 'package:flutter/material.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({Key? key}) : super(key: key);

  @override
  _StockScreenState createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  bool _alertasActivas = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Niveles de Stock')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Stock Mínimo por Defecto',
              icon: Icon(Icons.arrow_downward),
            ),
            initialValue: '10',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Stock Máximo por Defecto',
              icon: Icon(Icons.arrow_upward),
            ),
            initialValue: '100',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
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
          ),
          const Divider(),
        ],
      ),
    );
  }
}
