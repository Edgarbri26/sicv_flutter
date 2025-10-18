import 'package:flutter/material.dart';
import 'core/theme/app_themes.dart';
import 'ui/pages/home_page.dart';


class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Inventario',
      theme: Themes.defaultTheme,
      home: const HomePage(),
    );
  }
}