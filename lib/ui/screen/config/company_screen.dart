import 'package:flutter/material.dart';

class CompanyScreen extends StatefulWidget {
  const CompanyScreen({super.key});

  @override
  _CompanyScreenState createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Información de la Empresa')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nombre de la Empresa',
                icon: Icon(Icons.business),
              ),
              initialValue: 'Mi Inventario S.A. de C.V.',
              validator: (value) =>
                  value!.isEmpty ? 'Este campo es requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Dirección',
                icon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                icon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Datos Fiscales (RFC)',
                icon: Icon(Icons.policy),
              ),
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Guardar Cambios'),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
