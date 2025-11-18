// lib/ui/pages/screen/sale_screen.dart
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

  // Controlador para el campo de búsqueda
  final TextEditingController _searchController = TextEditingController();

  List<CategoryModel> _categories = [];

  // Categoría seleccionada actualmente
  int _selectedCategoryId = 0; // 0 para "Todos"

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadData(); // Carga los datos

    // Añade un listener al buscador para filtrar en tiempo real
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
      // 💡 Actualiza el StateProvider de búsqueda con el texto actual
      ref.read(saleSearchTermProvider.notifier).state = _searchController.text;
    });
  }

  // Carga y prepara los datos
  Future<void> _loadData() async {

    final loadedCategories = await _fetchCategories();

    // 2. Usar setState para actualizar la interfaz con los datos cargados
    if (mounted) {
      setState(() {
        // 💡 SOLUCIÓN: Inicializa la variable 'late' aquí
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
    // Usamos Column para añadir el buscador y filtros sobre la cuadrícula
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

        // --- 3. CUADRÍCULA DE PRODUCTOS (AHORA EXPANDIDA) ---
        Expanded(
          child: productsState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
            data: (products) {
              final filteredProducts = ref.watch(filteredProductsProvider); // Usar el provider derivado

              return filteredProducts.isEmpty
              ? Center(child: Text('No se encontraron productos.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  // --- MEJORA DE RESPONSIVIDAD ---
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200, // Ancho máx. de cada tarjeta
                    mainAxisSpacing: 16.0,
                    crossAxisSpacing: 16.0,
                    childAspectRatio: 0.7, // Ajusta la altura (Ancho / Alto)
                  ),
                  // --- FIN DE MEJORA ---
                  itemCount: filteredProducts.length, // Usa la lista filtrada
                  itemBuilder: (context, index) {
                    final product =
                        filteredProducts[index]; // Usa la lista filtrada
                    bool isOutOfStock = product.totalStock == 0;

                    return ProductCard(
                      product: product,
                      isOutOfStock: isOutOfStock,
                      
                      // 3. Pasar las acciones (callbacks)
                      // Llama a la función del widget padre (ProductListScreen)
                      onTap: () => widget.onProductAdded(product), 
                      
                      // Llama a la función de la pantalla principal
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
      // 'barrierDismissible' permite cerrar el diálogo tocando fuera (comportamiento estándar)
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        // Usamos AlertDialog por su layout estándar, pero lo personalizamos
        return AlertDialog(
          // Forma redondeada, como el modal
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          // Eliminamos el padding para que la imagen se pegue a los bordes
          contentPadding: EdgeInsets.zero,

          // Usamos MainAxisSize.min para que la columna no intente
          // ocupar toda la altura de la pantalla
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
                      // Asumo que tu producto tiene 'descripcion'
                      product.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // ubicacion
                    const SizedBox(height: 16),
                    Text(
                      // Asumo que tiene 'precio'
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
                // 1. Cerramos el diálogo
                Navigator.of(dialogContext).pop();
                // 2. Cerramos el ModalBottomSheet
                Navigator.of(context).pop();
                // 3. (Opcional) Navegamos a la página de detalle completa
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
