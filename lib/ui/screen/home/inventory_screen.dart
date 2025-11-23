// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Importar Riverpod
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/color_stock.dart';
import 'package:sicv_flutter/models/category_model.dart';
import 'package:sicv_flutter/models/product/product_model.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sicv_flutter/providers/product_provider.dart'; // Tu Provider
import 'package:sicv_flutter/services/category_service.dart';
import 'package:sicv_flutter/ui/widgets/atomic/drop_down_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/search_text_field_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/text_field_app.dart';

// 2. Definición correcta de ConsumerStatefulWidget
class InventoryDatatableScreen extends ConsumerStatefulWidget {
  const InventoryDatatableScreen({super.key});

  @override
  ConsumerState<InventoryDatatableScreen> createState() =>
      InventoryDatatableScreenState();
}

class InventoryDatatableScreenState extends ConsumerState<InventoryDatatableScreen> {
  // Categorías (se mantienen locales como pediste, aunque podrían ir a un provider)
  late List<CategoryModel> _allCategories = [];
  late List<CategoryModel> categoriesFilter = [];

  // Estado LOCAL solo para los filtros visuales
  String _searchQuery = '';
  CategoryModel? _selectedCategory;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  // El "dummy data" (_allProducts) se elimina porque ahora viene del Provider

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    // No necesitamos cargar productos aquí manualmente; el Provider lo hace al iniciarse.
  }

  @override
  Widget build(BuildContext context) {
    // 3. Escuchamos al Provider (La fuente de verdad)
    final productsState = ref.watch(productsProvider);

    return Scaffold(
      // Usamos .when para manejar los estados de carga/error/datos automáticamente
      body: productsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (allProducts) {
          // Calculamos los productos a mostrar "al vuelo"
          final displayProducts = _getFilteredProducts(allProducts);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KPI Dashboard usa TODOS los productos para calcular totales reales
                _buildKpiDashboard(allProducts),
                SizedBox(height: 16),
                // Filtros
                _buildFiltersAndSearch(),
                SizedBox(height: 16),
                // DataTable usa los productos FILTRADOS
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 0.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: AppColors.border, width: 3.0),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth,
                            ),
                            child: _buildDataTable(displayProducts),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _fetchCategories() async {
    try {
      _allCategories = await CategoryService().getAll();
      categoriesFilter = [
        CategoryModel(
          id: 0,
          name: 'Todas',
          status: true,
          description: 'Todas las categorías',
        ),
        ..._allCategories,
      ];
      if (mounted) setState(() {});
    } catch (e) {
      // Manejo de error silencioso para UI
    }
  }

  /// Método auxiliar para filtrar la lista que viene del Provider
  /// (Reemplaza a tu antiguo _filterProducts void)
  List<ProductModel> _getFilteredProducts(List<ProductModel> allProducts) {
    List<ProductModel> tempProducts = List.from(allProducts);

    // 1. Filtro Categoría
    if (_selectedCategory != null && _selectedCategory!.name != 'Todas') {
      tempProducts = tempProducts
          .where((product) => product.category.name == _selectedCategory!.name)
          .toList();
    }

    // 2. Filtro Búsqueda
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      tempProducts = tempProducts
          .where(
            (product) =>
                product.name.toLowerCase().contains(query) ||
                (product.sku?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    }

    // 3. Ordenamiento
    if (_sortColumnIndex != null) {
      tempProducts.sort((a, b) {
        dynamic aValue;
        dynamic bValue;

        switch (_sortColumnIndex) {
          case 1: // Producto
            aValue = a.name.toLowerCase();
            bValue = b.name.toLowerCase();
            break;
          case 2: // SKU
            aValue = a.sku?.toLowerCase() ?? '';
            bValue = b.sku?.toLowerCase() ?? '';
            break;
          case 3: // Categoría
            aValue = a.category.name.toLowerCase();
            bValue = b.category.name.toLowerCase();
            break;
          case 4: // Stock
            aValue = a.stockGenerals.length;
            bValue = b.stockGenerals.length;
            break;
          case 5: // Precio
            aValue = a.price;
            bValue = b.price;
            break;
          default:
            return 0;
        }

        final comparison = aValue.compareTo(bValue);
        return _sortAscending ? comparison : -comparison;
      });
    }
    return tempProducts;
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      // No llamamos a _filterProducts(), el build lo hará automáticamente
    });
  }

  /// KPI Dashboard (Ahora recibe la lista como parámetro)
  Widget _buildKpiDashboard(List<ProductModel> products) {
    double totalValue = products.fold(
      0,
      (sum, item) => sum + (item.price * item.stockGenerals.length),
    );
    int lowStockItems = products
        .where(
          (p) =>
              p.stockGenerals.isNotEmpty &&
              p.stockGenerals.length <= p.minStock,
        )
        .length;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;
          if (isWideScreen) {
            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildKpiCard(
                    'Valor Total (Precio)',
                    '\$${totalValue.toStringAsFixed(2)}',
                    Colors.blue.shade800,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: _buildKpiCard(
                    'Items (SKUs)',
                    products.length.toString(),
                    Colors.green.shade800,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: _buildKpiCard(
                    'Stock Bajo',
                    lowStockItems.toString(),
                    Colors.orange.shade800,
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard(
                        'Items (SKUs)',
                        products.length.toString(),
                        Colors.green.shade800,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _buildKpiCard(
                        'Stock Bajo',
                        lowStockItems.toString(),
                        Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard(
                        'Valor Total (Precio)',
                        '\$${totalValue.toStringAsFixed(2)}',
                        Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, Color color) {
    return Card(
      color: AppColors.secondary,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: AppColors.border, width: 2.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersAndSearch() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              bool isWideScreen = constraints.maxWidth > 600;
              if (isWideScreen) {
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SearchTextFieldApp(
                        onChanged: (value) {
                          // Solo actualizamos el estado local, el build filtra
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        labelText: 'Buscar por Nombre o SKU',
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: DropDownApp(
                        labelText: "Categorías",
                        hintText: "Selecciona una categoría...",
                        initialValue: _selectedCategory,
                        items: categoriesFilter,
                        itemToString: (CategoryModel categoria) =>
                            categoria.name,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedCategory = newValue!;
                          });
                        },
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    SearchTextFieldApp(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      labelText: 'Buscar por Nombre o SKU',
                    ),
                    SizedBox(height: 16),
                    DropDownApp(
                      labelText: "Categorías",
                      hintText: "Selecciona una categoría...",
                      initialValue: _selectedCategory,
                      items: categoriesFilter, // Usamos la lista filtrada
                      itemToString: (CategoryModel categoria) => categoria.name,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCategory = newValue!;
                        });
                      },
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<ProductModel> products) {
    return DataTable(
      horizontalMargin: 15.0,
      columnSpacing: 20.0,
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      dataRowColor: WidgetStateProperty.all(AppColors.background),
      headingRowColor: WidgetStateProperty.all(AppColors.border),
      headingRowHeight: 48.0,
      columns: [
        const DataColumn(
          label: Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text('Img', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        DataColumn(
          label: Text(
            'Producto',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onSort: _onSort,
        ),
        DataColumn(
          label: Text('SKU', style: TextStyle(fontWeight: FontWeight.bold)),
          onSort: _onSort,
        ),
        DataColumn(
          label: Text(
            'Categoría',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onSort: _onSort,
        ),
        DataColumn(
          label: Text('Stock', style: TextStyle(fontWeight: FontWeight.bold)),
          numeric: true,
          onSort: _onSort,
        ),
        DataColumn(
          label: Text('Precio', style: TextStyle(fontWeight: FontWeight.bold)),
          numeric: true,
          onSort: _onSort,
        ),
        DataColumn(
          label: Row(
            children: [
              SizedBox(width: 15.0),
              Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
      rows: products.map((product) {
        final stockColor = ColorStock().getColor(
          product.stockGenerals.length,
          product.minStock,
        );
        return DataRow(
          cells: [
            DataCell(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(product.imageUrl ?? ''),
                  onBackgroundImageError: (e, s) {},
                  child: (product.imageUrl == null || product.imageUrl!.isEmpty)
                      ? const Icon(
                          Icons.image_not_supported,
                          size: 20,
                          color: Colors.grey,
                        )
                      : null,
                ),
              ),
            ),
            DataCell(Text(product.name)),
            DataCell(Text(product.sku ?? '')),
            DataCell(Text(product.category.name)),
            DataCell(
              Text(
                product.stockGenerals.length.toString(),
                style: TextStyle(
                  color: stockColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataCell(Text('\$${product.price.toStringAsFixed(2)}')),
            DataCell(
              Row(
                children: [
                  SizedBox(width: 15.0),
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      size: 20,
                      color: Colors.blue.shade700,
                    ),
                    tooltip: 'Editar Producto',
                    onPressed: () => _editProduct(product),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.inventory_2,
                      size: 20,
                      color: Colors.green.shade700,
                    ),
                    tooltip: 'Ajustar Stock',
                    onPressed: () => _adjustStock(product),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      size: 20,
                      color: Colors.red.shade700,
                    ),
                    tooltip: 'Eliminar Producto',
                    onPressed: () => _deleteProduct(product),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  void _editProduct(ProductModel product) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Editando ${product.name}...')));
  }

  void _adjustStock(ProductModel product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Mostrando diálogo para ajustar stock de ${product.name}...',
        ),
      ),
    );
  }

  void _deleteProduct(ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar ${product.name}?'),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
            onPressed: () {
              // 4. Conexión para eliminar:
              ref.read(productsProvider.notifier).deleteProduct(product);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void addNewProduct() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    final skuController = TextEditingController();

    CategoryModel? selectedCategory;
    File? selectedImageFile;
    Uint8List? selectedImageBytes;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext modalContext) {
        return Padding(
          padding: MediaQuery.of(modalContext).viewInsets,
          child: StatefulBuilder(
            builder: (context, setStateModal) {
              Future<void> pickImage() async {
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                );

                if (image != null) {
                  if (kIsWeb) {
                    final bytes = await image.readAsBytes();
                    setStateModal(() {
                      selectedImageBytes = bytes;
                      selectedImageFile = null;
                    });
                  } else {
                    setStateModal(() {
                      selectedImageFile = File(image.path);
                      selectedImageBytes = null;
                    });
                  }
                }
              }

              return Container(
                height: MediaQuery.of(context).size.height * 0.85,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Registrar Nuevo Producto',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 24),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.border,
                                        width: 2,
                                      ),
                                      image: kIsWeb
                                          ? (selectedImageBytes != null
                                                ? DecorationImage(
                                                    image: MemoryImage(
                                                      selectedImageBytes!,
                                                    ),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null)
                                          : (selectedImageFile != null
                                                ? DecorationImage(
                                                    image: FileImage(
                                                      selectedImageFile!,
                                                    ),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null),
                                    ),
                                    child:
                                        (kIsWeb
                                            ? selectedImageBytes == null
                                            : selectedImageFile == null)
                                        ? const Center(
                                            child: Icon(
                                              Icons.add_a_photo_outlined,
                                              size: 40,
                                              color: AppColors.textSecondary,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    icon: Icon(
                                      (kIsWeb
                                              ? selectedImageBytes == null
                                              : selectedImageFile == null)
                                          ? Icons.add
                                          : Icons.edit,
                                      size: 18,
                                    ),
                                    label: Text(
                                      (kIsWeb
                                              ? selectedImageBytes == null
                                              : selectedImageFile == null)
                                          ? 'Añadir Imagen'
                                          : 'Cambiar Imagen',
                                    ),
                                    onPressed: pickImage,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextFieldApp(
                              controller: nameController,
                              labelText: 'Nombre del Producto',
                              prefixIcon: Icons.shopping_bag_outlined,
                            ),
                            const SizedBox(height: 16),
                            TextFieldApp(
                              controller: skuController,
                              labelText: 'SKU / Código',
                              prefixIcon: Icons.qr_code,
                              keyboardType: TextInputType.text,
                            ),
                            const SizedBox(height: 16),
                            DropDownApp(
                              labelText: "Categoría",
                              prefixIcon: Icons.category,
                              initialValue: selectedCategory,
                              items:
                                  _allCategories, // Usamos la lista completa para el formulario
                              itemToString: (CategoryModel categoria) =>
                                  categoria.name,
                              onChanged: (newValue) {
                                setStateModal(() {
                                  selectedCategory = newValue!;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFieldApp(
                                    controller: priceController,
                                    labelText: 'Precio',
                                    prefixIcon: Icons.attach_money,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFieldApp(
                                    controller: stockController,
                                    labelText: 'Stock Inicial',
                                    prefixIcon: Icons.inventory_2_outlined,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFieldApp(
                              controller: descriptionController,
                              labelText: 'Descripción (Opcional)',
                              maxLines: 3,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        TextButton(
                          child: const Text('CANCELAR'),
                          onPressed: () => Navigator.of(modalContext).pop(),
                        ),
                        const SizedBox(width: 8),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 250),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed:
                                (nameController.text.isEmpty ||
                                    skuController.text.isEmpty)
                                ? null
                                : () async {
                                    Uint8List? imageBytesToSend;
                                    if (kIsWeb) {
                                      imageBytesToSend = selectedImageBytes;
                                    } else if (selectedImageFile != null) {
                                      imageBytesToSend =
                                          await selectedImageFile!
                                              .readAsBytes();
                                    }

                                    if (selectedCategory == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Selecciona una categoría',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    try {
                                      // 5. CONEXIÓN PARA CREAR PRODUCTO:
                                      await ref
                                          .read(productsProvider.notifier)
                                          .createProduct(
                                            name: nameController.text,
                                            sku: skuController.text,
                                            categoryId: selectedCategory!.id,
                                            description:
                                                descriptionController.text,
                                            price:
                                                double.tryParse(
                                                  priceController.text,
                                                ) ??
                                                0.0,
                                            minStock:
                                                int.tryParse(
                                                  stockController.text,
                                                ) ??
                                                0,
                                            imageUrl: imageBytesToSend,
                                            isPerishable:
                                                false, // Ajusta según tu lógica de negocio
                                          );

                                      if (mounted) {
                                        Navigator.of(modalContext).pop();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Producto creado con éxito',
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    }
                                  },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.check, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'GUARDAR PRODUCTO',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      descriptionController.dispose();
      priceController.dispose();
      stockController.dispose();
      skuController.dispose();
    });
  }
}
