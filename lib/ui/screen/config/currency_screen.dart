import 'package:flutter/material.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({Key? key}) : super(key: key);

  @override
  _CurrencyScreenState createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  String _monedaSeleccionada = 'USD'; // Valor por defecto

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración de Moneda')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Tipo de Moneda Principal',
              icon: Icon(Icons.monetization_on),
            ),
            value: _monedaSeleccionada,
            items: ['USD', 'EUR', 'MXN', 'COP', 'ARS']
                .map(
                  (label) => DropdownMenuItem(child: Text(label), value: label),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _monedaSeleccionada = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Símbolo Monetario',
              icon: Icon(Icons.attach_money),
            ),
            initialValue: '\$',
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Número de Decimales',
              icon: Icon(Icons.format_list_numbered),
            ),
            initialValue: '2',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          ElevatedButton(child: const Text('Guardar'), onPressed: () {}),
        ],
      ),
    );
  }
}
