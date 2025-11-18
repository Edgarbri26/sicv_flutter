import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/models/category_model.dart';
import 'package:sicv_flutter/models/product_model.dart';
import 'package:sicv_flutter/providers/product_provider.dart';
import 'package:sicv_flutter/providers/sale_provider.dart';
import 'package:sicv_flutter/services/category_service.dart';
import 'package:sicv_flutter/ui/widgets/atomic/text_field_app.dart';
import 'package:sicv_flutter/ui/widgets/img_product.dart';
import 'package:sicv_flutter/ui/widgets/product_card.dart';

class SaleScreen extends ConsumerStatefulWidget {
  final Function(ProductModel) onProductAdded;
  const SaleScreen({super.key, required this.onProductAdded});

  @override
  ConsumerState<SaleScreen> createState() => SaleScreenState();
}

class SaleScreenState extends ConsumerState<SaleScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<CategoryModel> _categories = [];

  // Categoría seleccionada actualmente
  int _selectedCategoryId = 0; // 0 para "Todos"

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadData();

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(saleSearchTermProvider.notifier).state = _searchController.text;
    });
  }

  Future<void> _loadData() async {

    final loadedCategories = await _fetchCategories();

    if (mounted) {
      setState(() {
        _categories = loadedCategories;
      });
    }
  }

  Future<List<CategoryModel>> _fetchCategories() async {
    // 💡 ASUME que tienes un CategoryService con un método getAll()
    // Si no lo tienes, debes crearlo.
    return await CategoryService().getAllCategories();
  }

  // --- MEJORA DE LAYOUT ---
  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);
    return Column(
      children: [
        // --- 1. WIDGET DE BÚSQUEDA ---
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: 
          TextFieldApp(
            controller: _searchController, 
            labelText: 'Buscar por Nombre o SKU', 
            prefixIcon:Icons.search
          ),
        ),
        // --- 2. WIDGET DE FILTRO DE CATEGORÍAS ---
        _buildCategoryFilter(),

        // --- 3. CUADRÍCULA DE PRODUCTOS ---
        Expanded(
          child: productsState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
            data: (products) {
              final filteredProducts = ref.watch(filteredProductsProvider);

              return filteredProducts.isEmpty
              ? Center(child: Text('No se encontraron productos.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    mainAxisSpacing: 16.0,
                    crossAxisSpacing: 16.0,
                    childAspectRatio: 0.7, // Ajusta la altura (Ancho / Alto)
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product =
                        filteredProducts[index];
                    bool isOutOfStock = product.totalStock == 0;

                    return ProductCard(
                      product: product,
                      isOutOfStock: isOutOfStock,
                      onTap: () => widget.onProductAdded(product),
                      onLongPress: () => _mostrarDialogoDetalleProducto(context, product), 
                    );
                  }, 
                );  
              },  
          )
        ),
      ],
    );
  }

  /// Muestra un diálogo de vista rápida del producto.
  void _mostrarDialogoDetalleProducto(
    BuildContext context,
    ProductModel product,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Imagen como Cabecera ---
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: ImgProduct(imageUrl: product.imageUrl ?? ''),
                ),
              ),

              // --- Contenido de Texto (Detalles) ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      product.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "S/ ${product.price.toStringAsFixed(2)}",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // --- Acciones del Diálogo ---
          actions: [
            TextButton(
              child: const Text("CERRAR"),
              onPressed: () {
                // Importante: usar 'dialogContext' para cerrar solo el diálogo
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text("VER MÁS"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
                // (Opcional) Navegamos a la página de detalle completa
                // Navigator.push(context, MaterialPageRoute(builder: (_) => PaginaDetalleProducto(product: product)));
              },
            ),
          ],
        );
      },
    );
  }

  // Widget para la barra horizontal de categorías
  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final bool isSelected = category.id == _selectedCategoryId;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(category.name),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategoryId = category.id;
                  });
                  //_runFilter(); // Vuelve a filtrar
                }
              },
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
              backgroundColor: AppColors.secondary,
              shape: StadiumBorder(
                side: BorderSide(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
