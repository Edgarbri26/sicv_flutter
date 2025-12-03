import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/providers/category_provider.dart';
import 'package:sicv_flutter/ui/skeletom/cartd_sceleton.dart';
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/search_text_field_app.dart';

// --- IMPORTACIONES AÑADIDAS ---
import 'package:sicv_flutter/models/category_model.dart';
import 'package:sicv_flutter/ui/widgets/atomic/text_field_app.dart'; // Reemplaza con tu ruta real
import 'package:sicv_flutter/ui/widgets/atomic/checkbox_field_app.dart'; // Reemplaza con tu ruta real

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  CategoriasScreenState createState() => CategoriasScreenState();
}

class CategoriasScreenState extends ConsumerState<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  // Tu lógica de prefijos local se mantiene
  final Map<String, String> _prefixes = {};

  @override
  void initState() {
    super.initState();
    // Inicia la carga de datos desde la API
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryProvider);
    return Scaffold(
      appBar: AppBarApp(title: 'Categorías', iconColor: AppColors.textPrimary),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          // --- USA FUTUREBUILDER PARA MANEJAR ESTADOS ---
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SearchTextFieldApp(
                  controller: _searchController,
                  labelText: 'Buscar Categoría',
                  hintText: 'Ej. Electrónica',
                ),
              ),
              Expanded(
                child: categoryState.when(
                  loading: () => ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return const CategoryLoadingSkeleton();
                    },
                  ),
                  error: (error, stack) =>
                      Center(child: Text('Error al cargar categorías: $error')),
                  data: (categories) {
                    final filteredList = categories
                        .where(
                          (categoria) => categoria.name.toLowerCase().contains(
                            _searchController.text.toLowerCase(),
                          ),
                        )
                        .toList();
                    return ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        // El item ahora es un objeto CategoryModel
                        final category = filteredList[index];
                        final prefix = _prefixes[category.name];
                        final statusChip = Chip(
                          label: Text(
                            category.status ? 'Activo' : 'Inactivo',
                            style: TextStyle(
                              color: category.status
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          backgroundColor: category.status
                              ? Colors.green.withValues(alpha: 0.15)
                              : Colors.red.withValues(alpha: 0.15),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 3,
                            vertical: 0,
                          ),
                          side: BorderSide.none,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        );

                        return ListTile(
                          title: Row(
                            children: [
                              Text(category.name),
                              const SizedBox(width: 8),
                              statusChip,
                            ],
                          ),
                          leading: const Icon(Icons.category_outlined),
                          // Muestra el prefijo si existe, si no, la descripción
                          subtitle: prefix != null && prefix.isNotEmpty
                              ? Text('Prefijo: $prefix')
                              : (category.description.isNotEmpty
                                    ? Text(category.description)
                                    : null),
                          onTap: () => debugPrint(
                            'TODO: Ver subcategorías de ${category.name}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                // Pasa el objeto CategoryModel completo
                                onPressed: () => _editarCategoria(category),
                              ),
                              category.status
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.block,
                                        color: Colors.red,
                                      ),
                                      tooltip: 'Desactivar',
                                      onPressed: () =>
                                          _showDeactivateConfirmDialog(
                                            category,
                                          ),
                                    )
                                  : IconButton(
                                      onPressed: () =>
                                          _showActivateConfirmDialog(category),
                                      tooltip: 'Activar',
                                      icon: const Icon(
                                        Icons.restore,
                                        color: Colors.green,
                                      ),
                                    ),
                            ],
                          ),
                        );
                      },
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

  // Future<List<CategoryModel>> _fetchCategories() async {
  //   try {
  //     // Llama al servicio
  //     final categories = await _categoryService.getAll();
  //     // Guarda las listas originales y filtradas
  //     setState(() {
  //       _categoriasOriginales = categories;
  //       _categoriasFiltradas = categories;
  //     });
  //     return categories;
  //   } catch (e) {
  //     // Propaga el error para que FutureBuilder lo maneje
  //     throw Exception('Error al cargar categorías: $e');
  //   }
  // }

  // void _filtrarCategorias(String query) {
  //   final lowerCaseQuery = query.toLowerCase();
  //   setState(() {
  //     _categoriasFiltradas = _categoriasOriginales
  //         .where(
  //           // Filtra por el nombre de la categoría
  //           (categoria) =>
  //               categoria.name.toLowerCase().contains(lowerCaseQuery),
  //         )
  //         .toList();
  //   });
  // }

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
              TextFieldApp(
                controller: descriptionController,
                labelText: 'Descripción',
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

                if (name.isEmpty || description.isEmpty)
                  return; // Validación simple

                try {
                  // Llama al servicio para crear
                  ref
                      .read(categoryProvider.notifier)
                      .createCategory(name: name, description: description);
                  // final newCategory = await _categoryService.create(
                  //   name,
                  //   description,
                  // );

                  // Cierra el diálogo
                  if (!mounted) return;
                  Navigator.of(context).pop();

                  // Muestra confirmación
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Categoría "$name" creada'),
                      backgroundColor: Colors.green,
                    ),
                  );
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
    final descriptionController = TextEditingController(
      text: categoria.description,
    );
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
                  TextFieldApp(
                    controller: descriptionController,
                    labelText: 'Descripción',
                  ),
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
                      await ref
                          .read(categoryProvider.notifier)
                          .updateCategory(
                            id: categoria.id, // El ID de la categoría
                            name: name,
                            description: description,
                            status:
                                currentStatus, // El estado (activo/inactivo)
                          );

                      if (!mounted) return;
                      Navigator.of(context).pop(); // Cierra el diálogo

                      // 2. Muestra confirmación
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Categoría "$name" actualizada'),
                          backgroundColor: Colors.green,
                        ),
                      );
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

  void _showDeactivateConfirmDialog(CategoryModel category) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Desactivar Categoría'),
          content: Text(
            '¿Estás seguro de que deseas Desactivar "${category.name}"? Esta acción puede afectar a los productos asociados.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () async {
                try {
                  await ref
                      .read(categoryProvider.notifier)
                      .deactivateCategory(category.id);

                  if (!mounted) return;
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Categoría "${category.name}" desactivada'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al desactivar: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Desactivar'),
            ),
          ],
        );
      },
    );
  }

  void _showActivateConfirmDialog(CategoryModel category) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Activar Categoría'),
          content: Text(
            '¿Estás seguro de que deseas Activar "${category.name}"? Esta acción puede afectar a los productos asociados.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.green),
              onPressed: () async {
                try {
                  await ref
                      .read(categoryProvider.notifier)
                      .activateCategory(category.id);

                  if (!mounted) return;
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Categoría "${category.name}" activada'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al activar: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Activar'),
            ),
          ],
        );
      },
    );
  }
}
