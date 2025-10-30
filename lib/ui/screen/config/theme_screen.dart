import 'package:flutter/material.dart';
import 'package:sicv_flutter/ui/widgets/atomic/button_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/drop_down_app.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  _ThemeScreenState createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  String _theme = 'sistema';
  String _language = 'es';

  @override
  Widget build(BuildContext context) {
    final themes = ['sistema', 'claro', 'oscuro'];
    final languages = ['es', 'en'];

    return Scaffold(
      appBar: const AppBarApp(
        title: 'Interfaz y Tema',
        iconColor: Colors.black,
        toolbarHeight: 64.0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE0E0E0), 
                width: 1.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropDownApp<String>(
                    labelText: 'Tema de la Aplicación',
                    prefixIcon: Icons.palette,
                    initialValue: _theme,
                    items: themes,
                    itemToString: (s) {
                      switch (s) {
                        case 'claro':
                          return 'Modo Claro';
                        case 'oscuro':
                          return 'Modo Oscuro';
                        default:
                          return 'Automático (del Sistema)';
                      }
                    },
                    onChanged: (value) {
                      if (value != null) setState(() => _theme = value);
                    },
                  ),

                  const SizedBox(height: 16),

                  DropDownApp<String>(
                    labelText: 'Idioma del Sistema',
                    prefixIcon: Icons.language,
                    initialValue: _language,
                    items: languages,
                    itemToString: (s) => s == 'es' ? 'Español' : 'English',
                    onChanged: (value) {
                      if (value != null) setState(() => _language = value);
                    },
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD), 
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tema actual: ${_theme == 'sistema' ? 'Automático' : (_theme == 'claro' ? 'Claro' : 'Oscuro')}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          PrimaryButtonApp(
            text: 'Guardar Preferencias',
            icon: Icons.save,
            maxWidth: 250,
            onPressed: () {
              debugPrint('Guardar tema=$_theme, language=$_language');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Preferencias guardadas'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
