import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';
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
  // Mapa simple para almacenar prefijos por categoría (id o nombre -> prefijo)
  final Map<String, String> _prefixes = {};

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
    // Mostrar diálogo para editar prefijo de la categoría
    final controller = TextEditingController(text: _prefixes[categoria] ?? '');
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Prefijo para $categoria'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Ej. ELEC-'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final value = controller.text.trim();
                setState(() {
                  if (value.isEmpty) {
                    _prefixes.remove(categoria);
                  } else {
                    _prefixes[categoria] = value;
                  }
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Prefijo actualizado para $categoria'),
                  ),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarApp(title: 'Categorías', iconColor: AppColors.textPrimary),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: Column(
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
                    final prefix = _prefixes[categoria];
                    return ListTile(
                      title: Text(categoria),
                      leading: const Icon(Icons.category_outlined),
                      subtitle: prefix != null && prefix.isNotEmpty
                          ? Text('Prefijo: $prefix')
                          : null,
                      onTap: () =>
                          print('TODO: Ver subcategorías de $categoria'),
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarCategoria,
        tooltip: 'Agregar Categoría',
        child: const Icon(Icons.add),
      ),
    );
  }
}
