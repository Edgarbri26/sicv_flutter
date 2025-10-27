import 'package:flutter/material.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({Key? key}) : super(key: key);

  @override
  _ThemeScreenState createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  String _theme = 'sistema';
  String _language = 'es';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interfaz y Tema')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Tema de la Aplicación',
              icon: Icon(Icons.palette),
            ),
            value: _theme,
            items: const [
              DropdownMenuItem(
                value: 'sistema',
                child: Text('Automático (del Sistema)'),
              ),
              DropdownMenuItem(value: 'claro', child: Text('Modo Claro')),
              DropdownMenuItem(value: 'oscuro', child: Text('Modo Oscuro')),
            ],
            onChanged: (value) {
              setState(() => _theme = value!);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Idioma del Sistema',
              icon: Icon(Icons.language),
            ),
            value: _language,
            items: const [
              DropdownMenuItem(value: 'es', child: Text('Español')),
              DropdownMenuItem(value: 'en', child: Text('English')),
            ],
            onChanged: (value) {
              setState(() => _language = value!);
            },
          ),
        ],
      ),
    );
  }
}
