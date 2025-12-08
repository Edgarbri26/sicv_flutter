// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, use_build_context_synchronously
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sicv_flutter/config/app_permissions.dart';
import 'package:sicv_flutter/providers/current_user_permissions_provider.dart';
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';
import 'package:sidebarx/sidebarx.dart';

// Imports internos (Asegúrate de que las rutas sean correctas en tu proyecto)
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_sizes.dart';
import 'package:sicv_flutter/core/theme/color_stock.dart';
import 'package:sicv_flutter/models/category_model.dart';
import 'package:sicv_flutter/models/product/product_model.dart';
import 'package:sicv_flutter/providers/product_provider.dart';
import 'package:sicv_flutter/services/category_service.dart';
import 'package:sicv_flutter/ui/widgets/atomic/drop_down_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/my_side_bar.dart';
import 'package:sicv_flutter/ui/widgets/atomic/search_text_field_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/text_field_app.dart';
import 'package:sicv_flutter/ui/widgets/wide_layuout.dart';

class InventarioPage extends ConsumerStatefulWidget {
  final SidebarXController controller;
  const InventarioPage({super.key, required this.controller});

  @override
  ConsumerState<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends ConsumerState<InventarioPage> {
  // --- Estado Local para Filtros y UI ---
  late List<CategoryModel> _allCategories = [];
  late List<CategoryModel> categoriesFilter = [];
  String _searchQuery = '';
  CategoryModel? _selectedCategory;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    // La carga de productos la maneja Riverpod automáticamente al hacer watch
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos el proveedor de productos (Fuente de la verdad)
    final productsState = ref.watch(productsProvider);

    final userPermissions = ref.watch(currentUserPermissionsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= AppSizes.breakpoint;

        final hasAccessProducts = userPermissions.can(
          AppPermissions.createProduct,
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          // AppBar solo para móvil
          appBar: !isWide
              ? AppBarApp(
                  title: 'Gestión del Inventario',
                )
              : null,

          // Drawer solo para móvil
          drawer: isWide ? null : MySideBar(controller: widget.controller),

          // FAB conectado al formulario de creación
          floatingActionButton: hasAccessProducts
              ? FloatingActionButton.extended(
                  onPressed: () => showProductForm(),
                  backgroundColor: AppColors.primary,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Nuevo Producto',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : null,

          // Cuerpo de la aplicación
          body: productsState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) =>
                Center(child: Text('Error cargando inventario: $err')),
            data: (allProducts) {
              // Calculamos los productos filtrados "al vuelo"
              final displayProducts = _getFilteredProducts(allProducts);

              // Construimos el contenido principal
              final Widget content = SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KPI Dashboard usa TODOS los productos para totales reales
                    _buildKpiDashboard(allProducts),
                    const SizedBox(height: 16),
                    // Filtros
                    _buildFiltersAndSearch(),
                    const SizedBox(height: 16),
                    // DataTable usa los productos FILTRADOS
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        elevation: 0.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: const BorderSide(
                            color: AppColors.border,
                            width: 3.0,
                          ),
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
                    // Espacio extra para que el FAB no tape el último item
                    const SizedBox(height: 80),
                  ],
                ),
              );

              // Si es pantalla ancha, envolvemos en WideLayout
              if (isWide) {
                return WideLayout(
                  controller: widget.controller,
                  appbartitle: 'Gestión del Inventario',
                  child: content,
                );
              }

              // Si es móvil, devolvemos el contenido directo (SizedBox.fromSize era redundante aquí si ya tenemos Scaffold body)
              return content;
            },
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // LÓGICA DE NEGOCIO Y UI (Extraída de InventoryDatatableScreen)
  // ---------------------------------------------------------------------------

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
      debugPrint("Error fetching categories: $e");
    }
  }

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
            aValue = a.totalStock;
            bValue = b.totalStock;
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
    });
  }

  Widget _buildKpiDashboard(List<ProductModel> products) {
    double totalValue = products.fold(
      0,
      (sum, item) => sum + (item.price * item.totalStock),
    );
    int lowStockItems = products
        .where((p) => p.totalStock > 0 && p.totalStock <= p.minStock)
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
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: _buildKpiCard(
                    'Items (SKUs)',
                    products.length.toString(),
                    Colors.green.shade800,
                  ),
                ),
                const SizedBox(width: 8),
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildKpiCard(
                        'Stock Bajo',
                        lowStockItems.toString(),
                        Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
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
        side: const BorderSide(color: AppColors.border, width: 2.5),
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
              style: const TextStyle(
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
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        labelText: 'Buscar por Nombre o SKU',
                      ),
                    ),
                    const SizedBox(width: 16),
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
                    const SizedBox(height: 16),
                    DropDownApp(
                      labelText: "Categorías",
                      hintText: "Selecciona una categoría...",
                      initialValue: _selectedCategory,
                      items: categoriesFilter,
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
    final userPermissions = ref.watch(currentUserPermissionsProvider);
    final hasAccessUpdateProducts = userPermissions.can(
      AppPermissions.updateProduct,
    );
    final hasAccessDeleteProducts = userPermissions.can(
      AppPermissions.deleteProduct,
    );

    final showActions = hasAccessUpdateProducts || hasAccessDeleteProducts;

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
          label: const Text(
            'Producto',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onSort: _onSort,
        ),
        DataColumn(
          label: const Text(
            'SKU',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onSort: _onSort,
        ),
        DataColumn(
          label: const Text(
            'Categoría',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onSort: _onSort,
        ),
        DataColumn(
          label: const Text(
            'Stock',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          numeric: true,
          onSort: _onSort,
        ),
        DataColumn(
          label: const Text(
            'Precio',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          numeric: true,
          onSort: _onSort,
        ),
        if (showActions)
          DataColumn(
            label: SizedBox(
              width: 80, // Ancho FIJO para asegurar alineación
              child: Center(
                child: Text(
                  'Acciones',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
      rows: products.map((product) {
        final stockColor = ColorStock().getColor(
          product.totalStock,
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
                product.totalStock.toString(),
                style: TextStyle(
                  color: stockColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataCell(
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('\$${product.price.toStringAsFixed(2)}'),
              ),
            ),
            if (showActions)
              DataCell(
                SizedBox(
                  width: 80, // MISMO Ancho FIJO que el header
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Centramos los botones en ese ancho
                    children: [
                      if (hasAccessUpdateProducts)
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            size: 20,
                            color: Colors.blue.shade700,
                          ),
                          tooltip: 'Editar Producto',
                          // Visual adjustment: IconButtons have internal padding, reducing it helps alignment
                          padding: EdgeInsets.zero,
                          constraints:
                              const BoxConstraints(), // Optional: makes button compact
                          onPressed: () => _editProduct(product),
                        ),

                      if (hasAccessUpdateProducts && hasAccessDeleteProducts)
                        const SizedBox(
                          width: 15.0,
                        ), // Un poco más de aire entre iconos

                      if (hasAccessDeleteProducts)
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            size: 20,
                            color: Colors.red.shade700,
                          ),
                          tooltip: 'Eliminar Producto',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _deleteProduct(product),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }

  void _editProduct(ProductModel product) {
    showProductForm(productToEdit: product);
  }

  void _deleteProduct(ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar ${product.name}?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            onPressed: () {
              ref.read(productsProvider.notifier).deleteProduct(product);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MODAL FORM (Crear / Editar)
  // ---------------------------------------------------------------------------

  void showProductForm({ProductModel? productToEdit}) async {
    final bool isEditing = productToEdit != null;

    final nameController = TextEditingController(
      text: isEditing ? productToEdit.name : '',
    );
    final descriptionController = TextEditingController(
      text: isEditing ? productToEdit.description : '',
    );
    final priceController = TextEditingController(
      text: isEditing ? productToEdit.price.toString() : '',
    );
    final skuController = TextEditingController(
      text: isEditing ? productToEdit.sku : '',
    );
    final minStockController = TextEditingController(
      text: isEditing ? productToEdit.minStock.toString() : '',
    );
    bool isPerishable = isEditing ? productToEdit.perishable : false;

    CategoryModel? selectedCategory;
    if (isEditing) {
      try {
        selectedCategory = _allCategories.firstWhere(
          (c) => c.id == productToEdit.category.id,
        );
      } catch (e) {
        selectedCategory = null;
      }
    }

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

              ImageProvider? imageToShow;
              if (kIsWeb && selectedImageBytes != null) {
                imageToShow = MemoryImage(selectedImageBytes!);
              } else if (!kIsWeb && selectedImageFile != null) {
                imageToShow = FileImage(selectedImageFile!);
              } else if (isEditing &&
                  productToEdit.imageUrl != null &&
                  productToEdit.imageUrl!.isNotEmpty) {
                imageToShow = NetworkImage(productToEdit.imageUrl!);
              }

              void refresh() => setStateModal(() {});

              return Container(
                height: MediaQuery.of(context).size.height * 0.85,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      isEditing
                          ? 'Editar Producto'
                          : 'Registrar Nuevo Producto',
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
                                      image: imageToShow != null
                                          ? DecorationImage(
                                              image: imageToShow,
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: imageToShow == null
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
                                      imageToShow == null
                                          ? Icons.add
                                          : Icons.edit,
                                      size: 18,
                                    ),
                                    label: Text(
                                      imageToShow == null
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
                              onChanged: (_) => refresh(),
                            ),
                            const SizedBox(height: 16),
                            TextFieldApp(
                              controller: skuController,
                              labelText: 'SKU / Código',
                              prefixIcon: Icons.qr_code,
                              keyboardType: TextInputType.text,
                              onChanged: (_) => refresh(),
                            ),
                            const SizedBox(height: 16),
                            DropDownApp(
                              labelText: "Categoría",
                              prefixIcon: Icons.category,
                              initialValue: selectedCategory,
                              items: _allCategories,
                              itemToString: (CategoryModel categoria) =>
                                  categoria.name,
                              onChanged: (newValue) {
                                setStateModal(() {
                                  selectedCategory = newValue!;
                                });
                                refresh();
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
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    onChanged: (_) => refresh(),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFieldApp(
                                    controller: minStockController,
                                    labelText: 'Stock mínimo',
                                    prefixIcon: Icons.store_mall_directory,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    onChanged: (_) => refresh(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFieldApp(
                              controller: descriptionController,
                              labelText: 'Descripción (Opcional)',
                              maxLines: 3,
                              prefixIcon: Icons.description_outlined,
                              onChanged: (_) => refresh(),
                            ),
                            const SizedBox(height: 16),
                            SwitchListTile(
                              title: const Text('Producto Perecible'),
                              value: isPerishable,
                              onChanged: (bool value) {
                                setStateModal(() {
                                  isPerishable = value;
                                });
                                refresh();
                              },
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
                          constraints: const BoxConstraints(maxWidth: 250),
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
                                    skuController.text.isEmpty ||
                                    selectedCategory == null ||
                                    priceController.text.isEmpty ||
                                    (!isEditing &&
                                        minStockController.text.isEmpty) ||
                                    descriptionController.text.isEmpty)
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
                                        const SnackBar(
                                          content: Text(
                                            'Selecciona una categoría',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    try {
                                      if (isEditing) {
                                        await ref
                                            .read(productsProvider.notifier)
                                            .updateProduct(
                                              id: productToEdit.id,
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
                                              imageUrl: imageBytesToSend,
                                            );

                                        if (mounted) {
                                          Navigator.of(modalContext).pop();
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Producto actualizado con éxito',
                                              ),
                                            ),
                                          );
                                        }
                                      } else {
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
                                                    minStockController.text,
                                                  ) ??
                                                  0,
                                              imageUrl: imageBytesToSend,
                                              isPerishable: false,
                                            );

                                        if (mounted) {
                                          Navigator.of(modalContext).pop();
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Producto creado con éxito',
                                              ),
                                            ),
                                          );
                                        }
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
                              children: [
                                Icon(
                                  isEditing ? Icons.save_as : Icons.check,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isEditing
                                      ? 'ACTUALIZAR PRODUCTO'
                                      : 'GUARDAR PRODUCTO',
                                  style: const TextStyle(
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
      minStockController.dispose();
      skuController.dispose();
    });
  }
}
