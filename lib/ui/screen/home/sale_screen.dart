import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/core/exceptions/backend_exception.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_text_styles.dart';
import 'package:sicv_flutter/models/category_model.dart';
import 'package:sicv_flutter/models/client_model.dart';
import 'package:sicv_flutter/models/product/product_model.dart';
import 'package:sicv_flutter/models/sale/sale_item_model.dart';
import 'package:sicv_flutter/models/sale/sale_model.dart';
import 'package:sicv_flutter/models/type_payment_model.dart';
import 'package:sicv_flutter/providers/auth_provider.dart';
import 'package:sicv_flutter/providers/category_provider.dart';
import 'package:sicv_flutter/providers/product_provider.dart';
import 'package:sicv_flutter/providers/sale_provider.dart';
import 'package:sicv_flutter/providers/type_payment_provider.dart';

import 'package:sicv_flutter/services/client_service.dart';
import 'package:sicv_flutter/services/sale_service.dart';
import 'package:sicv_flutter/ui/skeletom/cartd_sceleton.dart';
import 'package:sicv_flutter/ui/widgets/add_client_form.dart';
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

  // late List<TypePaymentModel> _allTypePayments = [];
  TypePaymentModel? _selectedTypePayment;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    allClients();
    // allTypePayments();
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

  /*
  void allTypePayments() async {
    _allTypePayments = await TypePaymentService().getAll();
    print("Tipos de pago cargados: ${_allTypePayments.length}");
    setState(() {});
  }*/

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
          child: TextFieldApp(
            controller: _searchController,
            labelText: 'Buscar por Nombre o SKU',
            prefixIcon: Icons.search,
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
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            mainAxisSpacing: 16.0,
                            crossAxisSpacing: 16.0,
                            childAspectRatio:
                                0.7, // Ajusta la altura (Ancho / Alto)
                          ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        bool isOutOfStock = product.totalStock == 0;

                        return ProductCard(
                          product: product,
                          isOutOfStock: isOutOfStock,
                          onTap: () => _onProductAddedToSale(product),
                          onLongPress: () =>
                              _mostrarDialogoDetalleProducto(context, product),
                        );
                      },
                    );
            },
          ),
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
        child: Center(
          child: Text('Error cargando categorías: ${error.toString()}'),
        ),
      ),
      data: (categories) {
        final List<CategoryModel> categoriesWithAll = [
          CategoryModel(
            id: 0,
            name: 'Todos',
            description: 'Todos los productos',
            status: true,
          ),
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
                      ref.read(saleSelectedCategoryIdProvider.notifier).state =
                          category.id;
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

  void addNewClient() async {
    final bool? clientWasAdded = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext modalContext) {
        return AddClientForm(clientService: ClientService());
      },
    );

    if (clientWasAdded == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cliente agregado correctamente'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void showSaleDetail(BuildContext context) {
   ref.read(authProvider); // Si no usas el valor, esto no hace falta aquí.

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        const double sheetSize = 0.8;

        return Consumer(
          builder: (context, ref, child) {
            final typePaymentsState = ref.watch(typePaymentProvider);

            return StatefulBuilder(
              builder: (BuildContext context, StateSetter modalSetState) {
                double total = _itemsForSale.fold(
                  0,
                  (previousValue, element) =>
                      previousValue + (element.quantity * element.price),
                );
                
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
                          // ... (Tu código de la barra superior y título sigue igual) ...
                          Center(
                            child: Container(
                              width: 40, height: 5, margin: const EdgeInsets.only(bottom: 15),
                              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          Center(
                            child: Text("Detalles de la Venta", textAlign: TextAlign.center, style: AppTextStyles.headlineLarge),
                          ),
                          
                          const SizedBox(height: 10),
                          
                          // Selección de Cliente y Botón Nuevo
                          Row(
                            children: [
                              Expanded( // <-- RECOMENDACIÓN: Envuelve en Expanded si DropDownApp no tiene ancho fijo
                                child: DropDownApp(
                                  items: _allClients,
                                  initialValue: selectedClient,
                                  onChanged: (newValue) {
                                    // Usamos modalSetState para que el dropdown cambie visualmente
                                    modalSetState(() {
                                      selectedClient = newValue;
                                    });
                                    // Opcional: Si necesitas que la pantalla padre también se entere:
                                    // setState(() => selectedClient = newValue); 
                                  },
                                  itemToString: (client) => client.name,
                                  labelText: 'Seleccionar Cliente',
                                  prefixIcon: Icons.person,
                                ),
                              ),
                              const SizedBox(width: 10),
                              PrimaryButtonApp(
                                text: "Nuevo",
                                onPressed: () async {
                                  // 1. Abrimos el modal directamente AQUÍ
                                      final bool? clientWasAdded = await showModalBottomSheet<bool>(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent, 
                                        builder: (ctx) => AddClientForm( // <--- Asegúrate de importar este widget
                                          clientService: ClientService(), // O tu instancia de servicio
                                        ),
                                      );

                                      // 2. Si se agregó, refrescamos la lista
                                      if (clientWasAdded == true) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Cliente agregado correctamente'), 
                                            backgroundColor: Colors.green
                                          ),
                                        );

                                        final clientServiceTemp = ClientService(); 
                                        final newClients = await clientServiceTemp.getAll(); // O .getAll() según como se llame tu método
                                        
                                        modalSetState(() {
                                          _allClients = newClients;
                                          if (newClients.isNotEmpty) {
                                            selectedClient = newClients.last;
                                          }
                                        });
                                      }
                                },  
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Tipos de Pago (Riverpod)
                          typePaymentsState.when(
                            loading: () => const CategoryLoadingSkeleton(),
                            error: (error, stack) => Center(child: Text('Error: $error')),
                            data: (typePayments) {
                              return DropDownApp(
                                items: typePayments,
                                initialValue: _selectedTypePayment,
                                onChanged: (newValue) {
                                  modalSetState(() {
                                    _selectedTypePayment = newValue;
                                  });
                                },
                                itemToString: (tp) => tp.name,
                                labelText: 'Seleccionar Tipo de Pago',
                                prefixIcon: Icons.payment,
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          // Total y Botón Confirmar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Ahora este texto SÍ cambiará cuando edites items
                              Text(
                                "Total: \$${total.toStringAsFixed(2)}", 
                                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                              ),
                              PrimaryButtonApp(
                                text: "Confirmar",
                                onPressed: () {
                                  // Validaciones antes de guardar
                                  if (selectedClient == null) {
                                    // Mostrar error
                                    return;
                                  }
                                  _saveSale();
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),
                          const Divider(),

                          // Lista de Productos
                          Expanded(
                            child: _itemsForSale.isEmpty 
                              ? const Center(child: Text("No hay artículos agregados"))
                              : ListView.builder(
                                controller: scrollController, // Importante para DraggableScrollableSheet
                                itemCount: _itemsForSale.length,
                                itemBuilder: (context, index) {
                                  final item = _itemsForSale[index];
                                  return DetailProductCart(
                                    item: item,
                                    onTap: () {
                                      _mostrarDialogoEditarCantidad(
                                        context,
                                        item,
                                        (nuevaCantidad) {
                                          // Actualizamos el estado DEL MODAL
                                          modalSetState(() {
                                            item.quantity = nuevaCantidad;
                                          });
                                        },
                                      );
                                    },
                                    onDelete: () {
                                      modalSetState(() {
                                        _itemsForSale.removeAt(index);
                                      });
                                    },
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
      },
    );
  } 

  void _mostrarDialogoEditarCantidad(
    BuildContext context,
    ProductModel item,
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
                final int? nuevaCantidad = int.tryParse(
                  cantidadController.text,
                );

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
    ).whenComplete(() => cantidadController.clear());
  }

  void _onProductAddedToSale(ProductModel product) {
    setState(() {
      final index = _itemsForSale.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _itemsForSale[index].quantity = _itemsForSale[index].quantity + 1;
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
    // 1. Validaciones PRIMERO (Sin Navigator.pop)
    // Si hay error, solo mostramos mensaje y salimos con return.

    if (_itemsForSale.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La venta no puede estar vacía. Agrega productos.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Detiene la función aquí, NO cierra la pantalla
    }

    if (selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, seleccione un cliente.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedTypePayment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, seleccione un tipo de pago.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authState = ref.watch(authProvider);

    if (authState.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No hay sesión de usuario activa.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 2. Preparar los datos
    // Mapeamos los items directamente
    List<SaleItemModel> saleItems = _itemsForSale.map((item) {
      return SaleItemModel(
        productId: item.id,
        amount: item.quantity,
        unitCost: item.price,
        depotId: 1, // Asegúrate que este ID sea dinámico si manejas varios almacenes
      );
    }).toList();

    // 3. Crear el objeto venta
    final SaleModel sale = SaleModel.forCreation(
      clientCi: selectedClient!.clientCi,
      userCi: authState.user!.userCi,
      typePaymentId: _selectedTypePayment!.typePaymentId,
      items: saleItems,
    );

    // 4. Enviar al Backend
    try {
      // Opcional: Mostrar un indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await SaleService().createSale(sale);

      // Cerrar el indicador de carga
      if (mounted) Navigator.of(context).pop(); 

      // 5. ÉXITO: Aquí SÍ cerramos el modal de ventas y limpiamos
      if (mounted) {
        Navigator.of(context).pop(); // Cierra el modal de "Confirmar Venta"
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Venta registrada exitosamente.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        setState(() {
          _itemsForSale.clear();
          selectedClient = null;
          _selectedTypePayment = null;
        });
      }

    } on BackendException catch (e) {
      // Si hubo loading, hay que cerrarlo primero
      if (mounted) Navigator.of(context).pop(); 

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error al procesar'),
          content: Text(e.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Si hubo loading, hay que cerrarlo primero
      if (mounted) Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperado: $e'), backgroundColor: Colors.red),
      );
    }
  }
}