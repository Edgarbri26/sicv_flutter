import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_text_styles.dart';
import 'package:sicv_flutter/models/category_model.dart';
import 'package:sicv_flutter/models/client_model.dart';
import 'package:sicv_flutter/models/product_model.dart';
import 'package:sicv_flutter/models/sale_item_model.dart';
import 'package:sicv_flutter/models/sale_model.dart';
import 'package:sicv_flutter/models/type_payment_model.dart';
import 'package:sicv_flutter/providers/category_provider.dart';
import 'package:sicv_flutter/providers/product_provider.dart';
import 'package:sicv_flutter/providers/sale_provider.dart';
import 'package:sicv_flutter/services/client_service.dart';
import 'package:sicv_flutter/services/sale_service.dart';
import 'package:sicv_flutter/services/type_payment_service.dart';
import 'package:sicv_flutter/ui/widgets/atomic/button_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/drop_down_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/text_field_app.dart';
import 'package:sicv_flutter/ui/widgets/detail_product_cart.dart';
import 'package:sicv_flutter/ui/widgets/img_product.dart';
import 'package:sicv_flutter/ui/widgets/product_card.dart';

class SaleScreen extends ConsumerStatefulWidget {
  const SaleScreen({super.key});

  @override
  ConsumerState<SaleScreen> createState() => SaleScreenState();
}

class SaleScreenState extends ConsumerState<SaleScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;

  final List<ProductModel> _itemsForSale = [];
  ClientModel? selectedClient;
  List<ClientModel> _allClients = [];

  late List<TypePaymentModel> _allTypePayments = [];
  TypePaymentModel? _selectedTypePayment;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    allClients();
    allTypePayments();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void allClients() async {
    _allClients = await ClientService().getAll();
    print("Clientes cargados: ${_allClients.length}");
    setState(() {});
  }

  void allTypePayments() async {
    _allTypePayments = await TypePaymentService().getAll();
    print("Tipos de pago cargados: ${_allTypePayments.length}");
    setState(() {});
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(saleSearchTermProvider.notifier).state = _searchController.text;
    });
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
                      onTap: () => _onProductAddedToSale(product),
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
    final categoriesState = ref.watch(categoryProvider);

    final selectedCategoryId = ref.watch(saleSelectedCategoryIdProvider);

    return categoriesState.when(
      loading: () => const SizedBox(
        height: 50,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (error, stack) => SizedBox(
        height: 50,
        child: Center(child: Text('Error cargando categorías: ${error.toString()}')),
      ),
      data: (categories) {
        final List<CategoryModel> categoriesWithAll = [
          CategoryModel(id: 0, name: 'Todos', description: 'Todos los productos', status: true),
          ...categories,
        ];

        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categoriesWithAll.length,
            itemBuilder: (context, index) {
              final category = categoriesWithAll[index];
              final bool isSelected = category.id == selectedCategoryId;

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(category.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(saleSelectedCategoryIdProvider.notifier).state = category.id;
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
      },
    );
  }

/*  void showProductSearchModal() {
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, child) { 
            final modalHeight = MediaQuery.of(context).size.height * 0.8;
            
          
                    return Container(
                      height: modalHeight, 
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Añadir Producto a la Orden',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          TextFieldApp(
                            controller: _searchController, 
                            labelText: 'Buscar producto por nombre o SKU',
                            prefixIcon: Icons.search,
                            onChanged: filterModalList,
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.builder(
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = filteredProducts[index];
                                // Revisa si ya está en la orden principal
                                final bool isAlreadyAdded = _purchaseItems.any(
                                  (item) => item.product.id == product.id,
                                );

                                return Card(
                                  elevation: 0.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    side: BorderSide(
                                      color: AppColors.border,
                                      width: 3.0,
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  color: isAlreadyAdded ? Colors.grey[300] : null,
                                  child: ListTile(
                                    title: Text(product.name),
                                    subtitle: Text('Stock actual: ${product.totalStock}'),
                                    trailing: isAlreadyAdded
                                        ? Icon(Icons.check, color: Colors.green)
                                        : Icon(Icons.add),
                                    onTap: isAlreadyAdded
                                        ? null 
                                        : () => _addProductToPurchase(product),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
    ).whenComplete(
      () => _searchController.clear(),
    ); // Limpia el buscador al cerrar el modal
  }
*/

  void showSaleDetail(BuildContext context) {
    double total = _itemsForSale.fold(
      0,
      (previousValue, element) =>
          previousValue + (element.quantity * element.price),
    );
    showModalBottomSheet(
      
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {

        const double sheetSize = 0.8;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: sheetSize,
              minChildSize: 0.3,
              maxChildSize: sheetSize,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                            color: AppColors.border, 
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          textAlign: TextAlign.center,
                          "Detalles de la Venta",
                          style: AppTextStyles.headlineLarge,
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropDownApp(
                        items: _allClients,
                        initialValue: selectedClient, 
                        onChanged: (newValue) {
                          // Manejar el cambio de cliente seleccionado
                          setState(() {
                            selectedClient = newValue;
                          });
                        }, 
                        itemToString: (client) => client.name, 
                        labelText: 'Seleccionar Cliente',
                        prefixIcon: Icons.person,
                      ),
                      const SizedBox(height: 20),
                      DropDownApp(
                        items: _allTypePayments,
                        initialValue: _selectedTypePayment, 
                        onChanged: (newValue) {
                          // Manejar el cambio de tipo de pago seleccionado
                          setState(() {
                            _selectedTypePayment = newValue;
                          });
                        }, 
                        itemToString: (typePayment) => typePayment.name, 
                        labelText: 'Seleccionar Tipo de Pago',
                        prefixIcon: Icons.payment,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total: \$${total.toStringAsFixed(2)}",
                            style: AppTextStyles.bodyLarge,
                          ),
                          PrimaryButtonApp(
                            text: "Confirmar", 
                            onPressed: () {
                              // Lógica para confirmar la venta
                              _saveSale();
                              Navigator.of(context).pop(); // Cerrar el modal
                            }),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: _itemsForSale.length,
                          itemBuilder: (context, index) {
                            final item = _itemsForSale[index];
                            return DetailProductCart(
                              item: item,
                              onTap: () {
                                _mostrarDialogoEditarCantidad(context, item, (
                                  nuevaCantidad,
                                ) {
                                  modalSetState(() {
                                    item.quantity = nuevaCantidad;
                                  });
                                });
                              },
                              onDelete: () {
                                modalSetState(() {
                                  _itemsForSale.removeAt(index);
                                });
                              },
                              trailing: Row(
                                children: [
                                  // ... (Iconos de añadir/quitar)
                                  // Nota: Estos botones también deberían usar modalSetState
                                  // si quieres que actualicen la UI en tiempo real.
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _mostrarDialogoEditarCantidad(
    BuildContext context,
    ProductModel
    item, 
    Function(int) onConfirm,
  ) {
    final TextEditingController cantidadController = TextEditingController();
    cantidadController.text = item.quantity.toString();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Modificar Cantidad"),
          content: TextField(
            controller: cantidadController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Nueva cantidad",
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text("Confirmar"),
              onPressed: () {
                final int? nuevaCantidad = int.tryParse(cantidadController.text);

                if (nuevaCantidad != null && nuevaCantidad >= 0) {
                  onConfirm(nuevaCantidad);
                  Navigator.of(dialogContext).pop();
                } else {
                  // Opcional: Mostrar un error si el valor no es válido
                  // (ej: usando un SnackBar o moviendo la lógica a un validador)
                }
              },
            ),
          ],
        );
      },
    ).whenComplete(
      () => cantidadController.clear(),
    );
  }
  
  void _onProductAddedToSale(ProductModel product) {
    setState(() {
      final index = _itemsForSale.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _itemsForSale[index].quantity =
            _itemsForSale[index].quantity + 1;
      } else {
        _itemsForSale.add(product);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} añadido a la venta.'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _saveSale() async {
    List<SaleItemModel> saleItems = [];
    for (var item in _itemsForSale) {
      saleItems.add(
        SaleItemModel(
          productId: item.id,
          amount: item.quantity,
          unitCost: item.price,
          depotId: 1,
        ),
      );
    }
    SaleModel sale = SaleModel(
      clientCi: selectedClient!.clientCi, 
      userCi: "31350493", 
      typePaymentId: _selectedTypePayment!.typePaymentId,
      saleItems: saleItems,
    );

    try {
       await SaleService().createSale(sale);
    } catch (e) {
      print("Error al guardar la venta: $e");
    }
  }
}
