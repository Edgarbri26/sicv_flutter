import 'package:flutter/material.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  _CategoriasScreenState createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriesScreen> {
  final List<String> _categorias = ['Electrónica', 'Ropa', 'Alimentos'];

  void _agregarCategoria() {
    print('TODO: Mostrar diálogo para agregar categoría');
  }

  void _editarCategoria(int index) {
    print('TODO: Editar ${_categorias[index]}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorías y Subcategorías')),
      body: ListView.builder(
        itemCount: _categorias.length,
        itemBuilder: (context, index) {
          final categoria = _categorias[index];
          return ListTile(
            title: Text(categoria),
            leading: const Icon(Icons.category_outlined),
            // TODO: Implementar onTap para ver subcategorías
            onTap: () => print('TODO: Ver subcategorías de $categoria'),
            trailing: IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editarCategoria(index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarCategoria,
        child: const Icon(Icons.add),
        tooltip: 'Agregar Categoría',
      ),
    );
  }
}
