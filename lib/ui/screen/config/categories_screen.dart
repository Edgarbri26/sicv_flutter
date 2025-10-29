import 'package:flutter/material.dart';
import 'package:sicv_flutter/ui/widgets/atomic/button_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/search_text_field_app.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  _CategoriasScreenState createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriesScreen> {
  final List<String> _categoriasOriginales = [
    'Electrónica',
    'Ropa',
    'Alimentos',
    'Hogar',
    'Deportes',
    'Juguetes',
  ];
  List<String> _categoriasFiltradas = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _categoriasFiltradas = _categoriasOriginales;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filtrarCategorias(String query) {
    final lowerCaseQuery = query.toLowerCase();
    setState(() {
      _categoriasFiltradas = _categoriasOriginales
          .where(
            (categoria) => categoria.toLowerCase().contains(lowerCaseQuery),
          )
          .toList();
    });
  }

  void _agregarCategoria() {
    print('TODO: Mostrar diálogo para agregar categoría');
  }

  void _editarCategoria(String categoria) {
    print('TODO: Editar $categoria');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Editando categoría: $categoria')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Categorías y Subcategorías',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchTextFieldApp(
              controller: _searchController,
              labelText: 'Buscar Categoría',
              hintText: 'Ej. Electrónica',
              onChanged: _filtrarCategorias,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _categoriasFiltradas.length,
              itemBuilder: (context, index) {
                final categoria = _categoriasFiltradas[index];
                return ListTile(
                  title: Text(categoria),
                  leading: const Icon(Icons.category_outlined),
                  onTap: () => print('TODO: Ver subcategorías de $categoria'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editarCategoria(categoria),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarCategoria,
        tooltip: 'Agregar Categoría',
        child: const Icon(Icons.add),
      ),
    );
  }
}
