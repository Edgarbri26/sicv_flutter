import 'package:flutter/material.dart';

class SkuScreen extends StatefulWidget {
  const SkuScreen({Key? key}) : super(key: key);

  @override
  _SkuScreenState createState() => _SkuScreenState();
}

class _SkuScreenState extends State<SkuScreen> {
  bool _skuAutomatico = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Códigos y SKU')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text('Generar SKU automático'),
            subtitle: const Text(
              'Crear un SKU único al guardar un producto nuevo',
            ),
            secondary: const Icon(Icons.qr_code_scanner),
            value: _skuAutomatico,
            onChanged: (bool value) {
              setState(() {
                _skuAutomatico = value;
              });
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Prefijo por Defecto (Opcional)',
                icon: Icon(Icons.text_fields),
                hintText: 'PROD-',
              ),
              enabled: _skuAutomatico,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Gestionar Prefijos por Categoría'),
            subtitle: const Text('Asignar prefijos diferentes (p.ej. "ELEC-")'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              print('TODO: Abrir pantalla de prefijos por categoría');
            },
          ),
        ],
      ),
    );
  }
}
