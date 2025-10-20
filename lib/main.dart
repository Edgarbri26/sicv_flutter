import 'package:flutter/material.dart';
import 'ui/pages/inventory_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario-LasValentinas',
      theme: ThemeData(
        primaryColor: Color(0xFF128C7E),
        colorScheme: ColorScheme.light(
          primary: Color(0xFF128C7E),
          secondary: Color(0xFF25D366),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF128C7E),
          elevation: 0,
        ),
      ),
      home: InventoryScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}