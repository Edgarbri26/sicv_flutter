import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/button_app.dart';

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
    return Scaffold(
      appBar: AppBarApp(title: 'Interfaz y Tema', iconColor: AppColors.textPrimary,),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelStyle:  TextStyle(
                fontSize: 16.0,
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: AppColors.secondary,
              labelText: "Tema del Sistema",
              prefixIcon: Icon(Icons.palette),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  width: 3.0,
                  color: AppColors.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  width: 3.0,
                  color: AppColors.textSecondary,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            ),   
            initialValue: _theme,
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
            decoration: InputDecoration(
              labelStyle:  TextStyle(
                fontSize: 16.0,
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: AppColors.secondary,
              labelText: "Idioma del Sistema",
              prefixIcon: Icon(Icons.language),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  width: 3.0,
                  color: AppColors.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  width: 3.0,
                  color: AppColors.textSecondary,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            ),
            initialValue: _language,
            items: const [
              DropdownMenuItem(value: 'es', child: Text('Español')),
              DropdownMenuItem(value: 'en', child: Text('English')),
            ],
            onChanged: (value) {
              setState(() => _language = value!);
            },
          ),
          const SizedBox(height: 20),
          PrimaryButtonApp (
            text: 'Guardar Configuración',
            icon: Icons.save,
            onPressed: (){},
            isLoading: false,
            maxWidth: 400,
          ),
        ],
      ),
    );
  }
}
