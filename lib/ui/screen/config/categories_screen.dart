import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/search_text_field_app.dart';

// --- IMPORTACIONES AÑADIDAS ---
import 'package:sicv_flutter/models/category_model.dart'; // Reemplaza con tu ruta real
import 'package:sicv_flutter/services/category_service.dart';
import 'package:sicv_flutter/ui/widgets/atomic/text_field_app.dart'; // Reemplaza con tu ruta real
import 'package:sicv_flutter/ui/widgets/atomic/checkbox_field_app.dart'; // Reemplaza con tu ruta real

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  _CategoriasScreenState createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriesScreen> {
  // --- ESTADO MANEJADO POR LA API ---
  final CategoryService _categoryService = CategoryService();
  late Future<List<CategoryModel>> _categoriesFuture;
  List<CategoryModel> _categoriasOriginales = [];
  List<CategoryModel> _categoriasFiltradas = [];

  final TextEditingController _searchController = TextEditingController();
  // Tu lógica de prefijos local se mantiene
  final Map<String, String> _prefixes = {};

  @override
  void initState() {
    super.initState();
    // Inicia la carga de datos desde la API
    _categoriesFuture = _fetchCategories();
  }

  Future<List<CategoryModel>> _fetchCategories() async {
    try {
      // Llama al servicio
      final categories = await _categoryService.getCategories();
      // Guarda las listas originales y filtradas
      setState(() {
        _categoriasOriginales = categories;
        _categoriasFiltradas = categories;
      });
      return categories;
    } catch (e) {
      // Propaga el error para que FutureBuilder lo maneje
      throw Exception('Error al cargar categorías: $e');
    }
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
            // Filtra por el nombre de la categoría
            (categoria) => categoria.name.toLowerCase().contains(lowerCaseQuery),
          )
          .toList();
    });
  }

  // --- FUNCIÓN DE AGREGAR (IMPLEMENTADA) ---
  void _agregarCategoria() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nueva Categoría'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFieldApp(controller: nameController, labelText: 'Nombre'),
              SizedBox(height: 10),
              TextFieldApp(controller: descriptionController, labelText: 'Descripción'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final description = descriptionController.text.trim();

                if (name.isEmpty) return; // Validación simple

                try {
                  // Llama al servicio para crear
                  final newCategory =
                      await _categoryService.createCategory(name, description);
                  
                  // Cierra el diálogo
                  if (!mounted) return;
                  Navigator.of(context).pop();

                  // Muestra confirmación
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Categoría "${newCategory.name}" creada'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Recarga la lista
                  setState(() {
                    _categoriesFuture = _fetchCategories();
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al crear: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  // --- FUNCIÓN DE EDITAR (ADAPTADA) ---
  // Ahora recibe un objeto CategoryModel
  void _editarCategoria(CategoryModel categoria) {
    // Controladores pre-llenados con los datos actuales
    final nameController = TextEditingController(text: categoria.name);
    final descriptionController = TextEditingController(text: categoria.description);
    // Estado para manejar el 'status' (activo/inactivo)
    bool currentStatus = categoria.status;

    showDialog<void>(
      context: context,
      builder: (context) {
        // Usamos un StatefulWidget para que el Checkbox se actualice
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Editar ${categoria.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFieldApp(controller: nameController, labelText: 'Nombre'),
                  SizedBox(height: 10),
                  TextFieldApp(controller: descriptionController, labelText: 'Descripción'),
                  SizedBox(height: 10),
                  CheckboxFieldApp(
                    title: "Activo",
                    value: currentStatus,
                    onChanged: (newValue) {
                      setDialogState(() {
                        currentStatus = newValue ?? false;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final description = descriptionController.text.trim();

                    if (name.isEmpty) return; // Validación

                    try {
                      // 1. Llama al servicio de actualización
                      await _categoryService.updateCategory(
                        categoria.id, // El ID de la categoría
                        name,
                        description,
                        currentStatus, // El estado (activo/inactivo)
                      );

                      if (!mounted) return;
                      Navigator.of(context).pop(); // Cierra el diálogo

                      // 2. Muestra confirmación
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Categoría "${name}" actualizada'),
                          backgroundColor: Colors.green,
                        ),
                      );

                      // 3. Recarga la lista de categorías
                      setState(() {
                        _categoriesFuture = _fetchCategories();
                      });
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al actualizar: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
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
          constraints: const BoxConstraints(maxWidth: 600),
          // --- USA FUTUREBUILDER PARA MANEJAR ESTADOS ---
          child: FutureBuilder<List<CategoryModel>>(
            future: _categoriesFuture,
            builder: (context, snapshot) {
              // 1. ESTADO DE CARGA
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // 2. ESTADO DE ERROR
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              // 3. ESTADO DE ÉXITO (PERO VACÍO)
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No se encontraron categorías.'));
              }

              // 4. ESTADO DE ÉXITO (CON DATOS)
              // Si llegamos aquí, los datos están cargados en _categoriasFiltradas
              return Column(
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
                        // El item ahora es un objeto CategoryModel
                        final categoria = _categoriasFiltradas[index];
                        final prefix = _prefixes[categoria.name];

                        return ListTile(
                          title: Text(categoria.name),
                          leading: const Icon(Icons.category_outlined),
                          // Muestra el prefijo si existe, si no, la descripción
                          subtitle: prefix != null && prefix.isNotEmpty
                              ? Text('Prefijo: $prefix')
                              : (categoria.description.isNotEmpty
                                  ? Text(categoria.description)
                                  : null),
                          onTap: () =>
                              print('TODO: Ver subcategorías de ${categoria.name}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            // Pasa el objeto CategoryModel completo
                            onPressed: () => _editarCategoria(categoria),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
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