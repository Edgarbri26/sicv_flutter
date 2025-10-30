// lib/ui/pages/screen/sale_screen.dart

import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_sizes.dart';
import 'package:sicv_flutter/models/category.dart';
import 'package:sicv_flutter/models/product.dart';
import 'package:sicv_flutter/ui/widgets/Info_chip.dart';
import 'package:sicv_flutter/ui/widgets/img_product.dart';

class SaleScreen extends StatefulWidget {
  final Function(Product) onProductAdded;
  const SaleScreen({super.key, required this.onProductAdded});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  // --- MEJORA DE ESTADO ---
  // Lista "maestra" que nunca cambia
  late List<Product> _todosLosProductos;
  // Lista que se muestra en la UI y cambia con los filtros
  late List<Product> _productosFiltrados;
  // Controlador para el campo de búsqueda
  final TextEditingController _searchController = TextEditingController();
  // Lista de categorías (incluyendo "Todos")
  late List<ProductCategory> _categories;
  // Categoría seleccionada actualmente
  int _selectedCategoryId = 0; // 0 para "Todos"

  @override
  void initState() {
    super.initState();
    _loadData(); // Carga los datos

    // Añade un listener al buscador para filtrar en tiempo real
    _searchController.addListener(_runFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Carga y prepara los datos
  void _loadData() {
    // Simula la carga de productos (DEBERÍAS TRAERLOS DE TU API/BD)
    _todosLosProductos = [
      Product(
        id: 1,
        name: 'Harina PAN',
        description: '...',
        price: 1.40,
        stock: 50,
        category: ProductCategory(id: 1, name: 'Alimentos'),
        sku: 'ALI-001',
      ),
      Product(
        id: 2,
        name: 'Cigarros Marlboro',
        description: '...',
        price: 5.99,
        stock: 5,
        category: ProductCategory(id: 2, name: 'Tabaco'),
        sku: 'TAB-001',
      ),
      Product(
        id: 3,
        name: 'Café',
        description: '...',
        price: 10.99,
        stock: 0,
        category: ProductCategory(id: 3, name: 'Bebidas'),
        sku: 'BEB-001',
      ),
      Product(
        id: 4,
        name: 'Gaseosa 2L',
        description: '...',
        price: 2.5,
        stock: 50,
        category: ProductCategory(id: 3, name: 'Bebidas'),
        sku: 'BEB-002',
      ),
      Product(
        id: 5,
        name: 'Pan Campesino',
        description: '...',
        price: 2.0,
        stock: 15,
        category: ProductCategory(id: 1, name: 'Alimentos'),
        sku: 'ALI-002',
      ),
      Product(
        id: 6,
        name: 'Agua Minalba 1L',
        description: '...',
        price: 1.0,
        stock: 30,
        category: ProductCategory(id: 3, name: 'Bebidas'),
        sku: 'BEB-003',
      ),
    ];

    // Simula la carga de categorías (DEBERÍAS TRAERLAS DE TU API/BD)
    _categories = [
      ProductCategory(id: 0, name: 'Todos'), // Categoría especial
      ProductCategory(id: 1, name: 'Alimentos'),
      ProductCategory(id: 2, name: 'Tabaco'),
      ProductCategory(id: 3, name: 'Bebidas'),
    ];

    // Al inicio, la lista filtrada es igual a la lista completa
    _productosFiltrados = _todosLosProductos;
  }

  // --- LÓGICA DE FILTRADO ---
  void _runFilter() {
    List<Product> results = _todosLosProductos;
    String searchText = _searchController.text.toLowerCase();

    // 1. Filtrar por categoría (si no es "Todos")
    if (_selectedCategoryId != 0) {
      results = results
          .where((product) => product.category.id == _selectedCategoryId)
          .toList();
    }

    // 2. Filtrar por texto de búsqueda
    if (searchText.isNotEmpty) {
      results = results
          .where(
            (product) =>
                product.name.toLowerCase().contains(searchText) ||
                (product.sku ?? '').toLowerCase().contains(searchText),
          ) // Busca por nombre o SKU
          .toList();
    }

    // 3. Actualizar la UI
    setState(() {
      _productosFiltrados = results;
    });
  }

  // --- MEJORA DE LAYOUT ---
  @override
  Widget build(BuildContext context) {
    // Usamos Column para añadir el buscador y filtros sobre la cuadrícula
    return Column(
      children: [
        /*Expanded(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 100,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary
              ),
              child: Center(
                child: Text("Ejemplo", style: TextStyle(color: AppColors.secondary),),
              ),
            ),
          ),
        ),*/
        // --- 1. WIDGET DE BÚSQUEDA ---
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.secondary,
              labelText: 'Buscar por Nombre o SKU',
              prefixIcon: Icon(Icons.search),
              labelStyle: TextStyle(
                fontSize: 14.0, // <-- Cambia el tamaño de la fuente del label
                color: AppColors
                    .textSecondary, // (Opcional: define el color del label)
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  width: 2.0, // <-- Tu grosor deseado
                  color: AppColors.border, // Color del borde
                ),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  width: 3.0, // <-- Puedes poner un grosor mayor al enfocar
                  color: AppColors.textSecondary, // Color del borde al enfocar
                ),
              ),

              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
          ),
        ),

        // --- 2. WIDGET DE FILTRO DE CATEGORÍAS ---
        _buildCategoryFilter(),

        // --- 3. CUADRÍCULA DE PRODUCTOS (AHORA EXPANDIDA) ---
        Expanded(
          child: _productosFiltrados.isEmpty
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
                  itemCount:
                      _productosFiltrados.length, // Usa la lista filtrada
                  itemBuilder: (context, index) {
                    final product =
                        _productosFiltrados[index]; // Usa la lista filtrada
                    bool isOutOfStock = product.stock == 0;

                    return Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(
                          AppSizes.borderRadiusL,
                        ),
                        border: Border.all(color: AppColors.border, width: 2),
                      ),
                      child: InkWell(
                        onLongPress: () =>
                            _mostrarDialogoDetalleProducto(context, product),
                        onTap: isOutOfStock
                            ? null
                            : () => widget.onProductAdded(product),
                        child: Opacity(
                          opacity: isOutOfStock ? 0.5 : 1.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 3,
                                child: ImgProduct(
                                  imageUrl: product.imageUrl ?? '',
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final ancho = constraints.maxWidth;
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  ancho *
                                                  0.095, // Puedes ajustar el factor
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Spacer(),
                                          Row(
                                            spacing: AppSizes.spacingXXS,
                                            children: [
                                              InfoChip(
                                                text:
                                                    '\$${product.price.toStringAsFixed(2)}',
                                                color: AppColors.info,
                                              ),
                                              if (product.stock > 0)
                                                InfoChip(
                                                  text: '${product.stock} Uds.',
                                                  color: product.stock > 5
                                                      ? AppColors.success
                                                      : AppColors.edit,
                                                )
                                              else
                                                InfoChip(
                                                  text: 'Agotado',
                                                  color: AppColors.error,
                                                ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                    // return Card(
                    //   clipBehavior: Clip.antiAlias,
                    //   // color: AppColors.disabled,
                    //   elevation: 0,
                    //   shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(
                    //       AppSizes.borderRadiusM,
                    //     ),
                    //   ),
                    //   child: InkWell(
                    //     onTap: isOutOfStock
                    //         ? null
                    //         : () => widget.onProductAdded(product),
                    //     child: Opacity(
                    //       opacity: isOutOfStock ? 0.5 : 1.0,
                    //       child: Column(
                    //         crossAxisAlignment: CrossAxisAlignment.stretch,
                    //         children: [
                    //           Expanded(
                    //             flex: 3,
                    //             child: Container(
                    //               color: Colors.grey.shade200,
                    //               child:
                    //                   (product.imageUrl != null &&
                    //                       product.imageUrl!.isNotEmpty)
                    //                   ? Image.network(
                    //                       product.imageUrl!,
                    //                       fit: BoxFit.cover,
                    //                     )
                    //                   : Icon(
                    //                       Icons.inventory_2,
                    //                       size: 40,
                    //                       color: Colors.grey.shade400,
                    //                     ),
                    //             ),
                    //           ),
                    //           Expanded(
                    //             flex: 2,
                    //             child: Padding(
                    //               padding: const EdgeInsets.all(8.0),
                    //               child: Column(
                    //                 crossAxisAlignment:
                    //                     CrossAxisAlignment.start,
                    //                 children: [
                    //                   Text(
                    //                     product.name,
                    //                     style: TextStyle(
                    //                       fontWeight: FontWeight.bold,
                    //                       fontSize: 16,
                    //                     ),
                    //                     maxLines: 2,
                    //                     overflow: TextOverflow.ellipsis,
                    //                   ),
                    //                   Spacer(),
                    //                   Text(
                    //                     '\$${product.price.toStringAsFixed(2)}',
                    //                     style: TextStyle(
                    //                       fontWeight: FontWeight.bold,
                    //                       color: Theme.of(context).primaryColor,
                    //                       fontSize: 15,
                    //                     ),
                    //                   ),
                    //                   // --- MEJORA DE UI (STOCK) ---
                    //                   if (isOutOfStock)
                    //                     Text(
                    //                       'Agotado',
                    //                       style: TextStyle(
                    //                         color: Colors.red,
                    //                         fontWeight: FontWeight.bold,
                    //                         fontSize: 10,
                    //                       ),
                    //                     )
                    //                   else if (product.stock <=
                    //                       10) // Muestra si queda poco stock
                    //                     Text(
                    //                       'Quedan: ${product.stock}',
                    //                       style: TextStyle(
                    //                         color: Colors.orange.shade800,
                    //                         fontWeight: FontWeight.bold,
                    //                         fontSize: 10,
                    //                       ),
                    //                     ),
                    //                 ],
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // );
                  },
                ),
        ),
      ],
    );
  }

  /// Muestra un diálogo de vista rápida del producto.
  void _mostrarDialogoDetalleProducto(BuildContext context, Product product) {
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
                  child:
                      (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                      ? Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) =>
                              progress == null
                              ? child
                              : Center(child: CircularProgressIndicator()),
                          errorBuilder: (context, error, stackTrace) =>
                              _buildImagePlaceholder(),
                        )
                      : _buildImagePlaceholder(),
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
                      product.description ??
                          "Este producto no tiene descripción.",
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
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

  /// Widget modular para mostrar la vista previa de un producto en la lista horizontal.
  /// (Necesitarás un modelo 'Product' con 'nombre' e 'imageUrl' o adaptarlo)
  // 1. La firma de la función ahora acepta 'BuildContext'
  Widget _buildProductPreviewCard(BuildContext context, Product product) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12.0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        // 2. Usamos InkWell para el efecto 'ripple' y el onTap
        child: InkWell(
          onTap: () {
            // 3. Llamamos a nuestra nueva función de diálogo
            _mostrarDialogoDetalleProducto(context, product);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Imagen del Producto (Sin cambios) ---
              SizedBox(
                height: 150,
                width: double.infinity,
                child:
                    (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) =>
                            progress == null
                            ? child
                            : Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                        errorBuilder: (context, error, stackTrace) =>
                            _buildImagePlaceholder(),
                      )
                    : _buildImagePlaceholder(),
              ),

              // --- Nombre del Producto (Sin cambios) ---
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  product.name,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper para el placeholder de imagen (lo usaremos de nuevo)
  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_not_supported,
          size: 50,
          color: Colors.grey[400],
        ),
      ),
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
                  _runFilter(); // Vuelve a filtrar
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
