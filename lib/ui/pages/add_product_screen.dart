// lib/screens/add_product_screen.dart

import 'package:flutter/material.dart';
import 'package:sicv_flutter/ui/widgets/add_product_form.dart';

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir Producto')),
      body: const AddProductForm(),
    );
  }
}