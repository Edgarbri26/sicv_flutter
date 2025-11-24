import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_sizes.dart';
import 'package:sicv_flutter/models/depot/depot_model.dart';
import 'package:sicv_flutter/models/product/product_model.dart';
import 'package:sicv_flutter/models/provider_model.dart';
import 'package:sicv_flutter/models/purchase/purchase_item_controller.dart';
// IMPORTANTE: Importa solo los modelos nuevos
import 'package:sicv_flutter/models/purchase/purchase_model.dart';
import 'package:sicv_flutter/models/purchase/purchase_item_model.dart';
import 'package:sicv_flutter/models/type_payment_model.dart';
import 'package:sicv_flutter/providers/auth_provider.dart'; // Necesitas el auth para el UserCI
import 'package:sicv_flutter/providers/product_provider.dart';
import 'package:sicv_flutter/providers/providers_provider.dart';
import 'package:sicv_flutter/providers/type_payment_provider.dart';
import 'package:sicv_flutter/services/depot_service.dart';
import 'package:sicv_flutter/services/purchase_service.dart';
import 'package:sicv_flutter/ui/skeletom/cartd_sceleton.dart';
import 'package:sicv_flutter/ui/widgets/atomic/button_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/drop_down_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/my_side_bar.dart';
import 'package:sicv_flutter/ui/widgets/atomic/text_field_app.dart';
import 'package:sidebarx/sidebarx.dart';

class PurchaseScreen extends ConsumerStatefulWidget {
  // Si usas Sidebar, necesitas pasar el controller
  final SidebarXController? controller; 
  const PurchaseScreen({super.key, this.controller});

  @override
  ConsumerState<PurchaseScreen> createState() => PurchaseScreenState();
}

class PurchaseScreenState extends ConsumerState<PurchaseScreen> {
  final DepotService _depotService = DepotService();
  final PurchaseService _purchaseService = PurchaseService();

  ProviderModel? _selectedProvider;
  TypePaymentModel? _selectedTypePayment;
  bool _isRegistering = false;

  // Carrito de compra (UI Helper)
  final List<PurchaseDetail> _purchaseItems = [];
  List<DepotModel> _allDepots = [];

  double _totalCost = 0.0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (var item in _purchaseItems) {
      item.quantityController.dispose();
      item.costController.dispose();
      item.expirationDateController?.dispose();
    }
    super.dispose();
  }

  void _loadData() async {
    try {
      final depots = await _depotService.getDepots();
      if (mounted) {
        setState(() {
          _allDepots = depots;
        });
      }
    } catch (e) {
      debugPrint("Error cargando depósitos: $e");
    }
  }

   /// Recalcula el costo total de la orden
  void _updateTotalCost() {
    double total = 0.0;
    for (var item in _purchaseItems) {
      final quantity = int.tryParse(item.quantityController.text) ?? 0;
      final cost = double.tryParse(item.costController.text) ?? 0.0;
      total += (quantity * cost);
    }
    setState(() {
      _totalCost = total;
    });
  }

  /// Añade un producto a la lista de compra
  void _addProductToPurchase(ProductModel product) {
    // Evita añadir duplicados
    if (_purchaseItems.any((item) => item.product.id == product.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} ya está en la orden.')),
      );
      return;
    }
    // Crea los controladores para este nuevo item
    final quantityController = TextEditingController(text: '1');
    // Usamos el precio de VENTA como *sugerencia* de costo, pero es editable
    final costController = TextEditingController(
      text: product.price.toStringAsFixed(2),
    );

    DepotModel? initialDepot = (_allDepots.isNotEmpty)
        ? _allDepots.first
        : null;

    TextEditingController? expirationDateController;

    if (product.perishable) {
      expirationDateController = TextEditingController();
    }
    // Añade listeners para que el total se actualice automáticamente
    quantityController.addListener(_updateTotalCost);
    costController.addListener(_updateTotalCost);

    final newItem = PurchaseDetail(
      product: product,
      quantityController: quantityController,
      costController: costController,
      expirationDateController: expirationDateController,
      selectedDepot: initialDepot,
    );

    setState(() {
      _purchaseItems.add(newItem);
    });
    _updateTotalCost(); // Actualiza el total
    Navigator.pop(context); // Cierra el modal de búsqueda
  }

  /// Quita un producto de la lista
  void _removeItem(int index) {
    // Primero, hay que limpiar los controllers
    _purchaseItems[index].quantityController.removeListener(_updateTotalCost);
    _purchaseItems[index].costController.removeListener(_updateTotalCost);
    _purchaseItems[index].quantityController.dispose();
    _purchaseItems[index].costController.dispose();
    _purchaseItems[index].expirationDateController?.dispose();

    setState(() {
      _purchaseItems.removeAt(index);
    });
    _updateTotalCost(); // Actualiza el total
  }

  /// Guarda la compra (LÓGICA CORREGIDA)
  void _registerPurchase() async {
    final authState = ref.read(authProvider); // Obtenemos usuario real

    setState(() => _isRegistering = true);

    // Validaciones básicas
    if (_selectedProvider == null) {
      _showError('Por favor, selecciona un proveedor.');
      return;
    }
    if (_selectedTypePayment == null) {
      _showError('Por favor, selecciona un tipo de pago.');
      return;
    }
    if (_purchaseItems.isEmpty) {
      _showError('No has añadido productos a la orden.');
      return;
    }
    if (authState.user == null) {
      _showError('Error de sesión. Vuelve a iniciar sesión.');
      return;
    }

    // 1. Construir la lista unificada de items
    final List<PurchaseItemModel> itemsToSend = [];

    for (var item in _purchaseItems) {
      final amount = int.tryParse(item.quantityController.text) ?? 0;
      final unitCost = double.tryParse(item.costController.text) ?? 0.0;

      if (amount <= 0) {
        _showError('La cantidad del producto ${item.product.name} debe ser mayor a 0.');
        return;
      }

      if (item.selectedDepot == null) {
        _showError('Selecciona un depósito para ${item.product.name}.');
        return;
      }

      DateTime? expirationDate;
      // Si es perecedero, validamos y parseamos la fecha
      if (item.product.perishable) {
        if (item.expirationDateController == null || item.expirationDateController!.text.isEmpty) {
          _showError('Falta fecha de vencimiento para ${item.product.name}.');
          return;
        }
        expirationDate = DateTime.tryParse(item.expirationDateController!.text);
        if (expirationDate == null) {
           _showError('Formato de fecha inválido para ${item.product.name}.');
           return;
        }
      }

      // Agregamos a la lista única (PurchaseItemModel maneja ambos casos)
      itemsToSend.add(PurchaseItemModel(
        productId: item.product.id,
        depotId: item.selectedDepot!.depotId,
        amount: amount,
        unitCost: unitCost,
        expirationDate: expirationDate, // Será null si no es perecedero
      ));
    }

    // 2. Crear el objeto PurchaseModel para envío
    final purchase = PurchaseModel.forCreation(
      providerId: _selectedProvider!.id,
      userCi: authState.user!.userCi, // Usuario real
      typePaymentId: _selectedTypePayment!.typePaymentId,
      items: itemsToSend,
    );

    // 3. Enviar al servicio
    try {
      await _purchaseService.createPurchase(purchase);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compra registrada exitosamente'), backgroundColor: Colors.green),
      );

      // Limpiar todo
      _searchController.clear();
      ref.invalidate(productsProvider); // Recargar productos para actualizar stock
      
      setState(() {
        _purchaseItems.clear();
        _selectedProvider = null;
        _selectedTypePayment = null;
        _totalCost = 0.0;
        _isRegistering = false;
      });

    } catch (e) {
      _showError('Error al registrar: $e');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
    setState(() => _isRegistering = false);
  }

  // ... [RESTO DE MÉTODOS DE UI: _buildProductList, etc. IGUALES] ...
  
  // Asegúrate de incluir _updateTotalCost, _addProductToPurchase, _removeItem, 
  // showProductSearchModal, _buildProductList, etc. tal cual los tenías, 
  // ya que la lógica visual es correcta.
  // El cambio crítico fue en _registerPurchase y los imports.
   void showProductSearchModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, child) {
            final productsState = ref.watch(productsProvider);
            final modalHeight = MediaQuery.of(context).size.height * 0.8;

            return productsState.when(
              loading: () => Container(
                height: modalHeight,
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return const CategoryLoadingSkeleton();
                  },
                ),
              ),
              error: (error, stack) => Container(
                height: modalHeight,
                child: Center(child: Text('Error: $error')),
              ),
              data: (products) {
                List<ProductModel> supplierProducts = productsState.value ?? [];
                List<ProductModel> filteredProducts = supplierProducts;
                return StatefulBuilder(
                  builder: (modalContext, modalSetState) {
                    void filterModalList(String query) {
                      modalSetState(() {
                        if (query.isEmpty) {
                          filteredProducts = supplierProducts;
                        } else {
                          filteredProducts = supplierProducts
                              .where(
                                (p) =>
                                    p.name.toLowerCase().contains(
                                      query.toLowerCase(),
                                    ) ||
                                    (p.sku ?? '').toLowerCase().contains(
                                      query.toLowerCase(),
                                    ),
                              )
                              .toList();
                        }
                      });
                    }

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
                                  color: isAlreadyAdded
                                      ? Colors.grey[300]
                                      : null,
                                  child: ListTile(
                                    title: Text(product.name),
                                    subtitle: Text(
                                      'Stock actual: ${product.totalStock}',
                                    ),
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
              },
            );
          },
        );
      },
    ).whenComplete(
      () => _searchController.clear(),
    ); // Limpia el buscador al cerrar el modal
  }

  @override
  Widget build(BuildContext context) {
    // ... Tu método build original está bien, solo asegúrate de que
    // use MySideBar si es necesario o lo quite si solo es un modal.
    // Aquí te dejo la estructura base de tu build:
    
    final typePaymentsState = ref.watch(typePaymentProvider);
    final providersState = ref.watch(providersProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= AppSizes.breakpoint;
        
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: !isWide ? AppBar(title: const Text("Registrar Compra")) : null,
          drawer: isWide || widget.controller == null ? null : MySideBar(controller: widget.controller!),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.add),
            label: const Text('Añadir Producto'),
            onPressed: showProductSearchModal, // Usa tu método existente
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                children: [
                   Expanded(
                     child: SingleChildScrollView(
                       padding: const EdgeInsets.all(16),
                       child: Column(
                         children: [
                           // Selectores
                           _buildProviderSelector(providersState),
                           const SizedBox(height: 16),
                           _buildTypePaymentSelector(typePaymentsState),
                           const Divider(height: 32),
                           
                           // Lista de Productos
                           _buildProductList(),
                         ],
                       ),
                     ),
                   ),
                   // Footer con total y botón guardar
                   _buildSummaryAndSave(),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  // Helper para el selector de Proveedores (Extraído para limpieza)
  Widget _buildProviderSelector(AsyncValue<List<ProviderModel>> state) {
    return state.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, s) => Text("Error proveedores: $e"),
      data: (providers) => DropDownApp(
        items: providers,
        initialValue: _selectedProvider,
        onChanged: (v) => setState(() => _selectedProvider = v),
        itemToString: (p) => p.name,
        labelText: 'Proveedor',
        prefixIcon: Icons.local_shipping,
      ),
    );
  }

  // Helper para el selector de Pagos
  Widget _buildTypePaymentSelector(AsyncValue<List<TypePaymentModel>> state) {
    return state.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, s) => Text("Error pagos: $e"),
      data: (types) => DropDownApp(
        items: types,
        initialValue: _selectedTypePayment,
        onChanged: (v) => setState(() => _selectedTypePayment = v),
        itemToString: (t) => t.name,
        labelText: 'Método de Pago',
        prefixIcon: Icons.payment,
      ),
    );
  }
  
  // Copia aquí tus métodos _buildProductList, _buildSummaryAndSave, etc.
  Widget _buildProductList() {
    if (_purchaseItems.isEmpty) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Text(
            'Añade productos a la orden usando el botón (+).',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 600),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: _purchaseItems.length,
        itemBuilder: (context, index) {
          final item = _purchaseItems[index];
          return _buildPurchaseItemTile(item, index, () => _removeItem(index));
        },
      ),
    );
  }

    Widget _buildPurchaseItemTile(
    PurchaseDetail item,
    int index,
    VoidCallback onRemove,
  ) {
    return Card(
      elevation: 0.0,
      color: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: const BorderSide(color: AppColors.border, width: 2.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección Superior: Nombre, SKU y Botón Eliminar
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                item.product.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(item.product.sku ?? 'Sin SKU'),
              trailing: IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red[700]),
                tooltip: 'Eliminar item',
                onPressed: onRemove,
              ),
            ),
            const SizedBox(height: 8),
            // Sección Inferior: Campos de Cantidad y Costo (Usando Wrap)
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                // --- Campo de Cantidad ---
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 100,
                    maxWidth: 150,
                  ),
                  child: TextFieldApp(
                    controller: item.quantityController,
                    labelText: 'Cantidad',
                    prefixIcon: Icons.inventory_2_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),

                // --- Campo de Costo ---
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 160,
                    maxWidth: 160,
                  ),
                  child: TextFieldApp(
                    controller: item.costController,
                    labelText: 'Costo por Unidad',
                    prefixIcon: Icons.attach_money,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                  ),
                ),

                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 160,
                    maxWidth: 160,
                  ),
                  child: DropDownApp(
                    labelText: 'Depósito',
                    hintText: 'Selecciona un depósito...',
                    initialValue: item.selectedDepot,
                    items: _allDepots,
                    onChanged: (newValue) {
                      setState(() {
                        item.selectedDepot = newValue;
                      });
                    },
                    itemToString: (DepotModel depot) {
                      return depot.name;
                    },
                  ),
                ),
                if (item.product.perishable)
                  _buildExpirationDateField(item.expirationDateController),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpirationDateField(TextEditingController? controller) {
    // Es crucial que el controlador no sea nulo antes de usarlo
    if (controller == null) return const SizedBox.shrink();

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 160, maxWidth: 160),
      child: TextFieldApp(
        controller: controller,
        labelText: 'F. Vencimiento',
        prefixIcon: Icons.calendar_today,
        readOnly: true,
        onTap: () async {
          // Implementación del DatePicker
          final DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(), // Fecha inicial
            firstDate:
                DateTime.now(), // No se pueden seleccionar fechas pasadas
            lastDate: DateTime(2050), // Límite superior
          );

          if (pickedDate != null) {
            // Formatea la fecha seleccionada (YYYY-MM-DD es común para APIs)
            final formattedDate =
                "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";

            // Actualiza el controlador de texto con la fecha formateada
            controller.text = formattedDate;
          }
        },
      ),
    );
  }


  Widget _buildSummaryAndSave() {
      return Card(
        color: AppColors.secondary,
        elevation: 0.0,
        // 2. Define el borde exterior usando 'shape'
        shape: RoundedRectangleBorder(
          // Define el radio de las esquinas
          borderRadius: BorderRadius.circular(8.0),

          // Define el borde (grosor y color)
          side: BorderSide(
            color: AppColors.border, // El color del borde
            width: 3.0, // El grosor del borde
          ),
        ),

        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL DE LA ORDEN:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '\$${_totalCost.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButtonApp(
                text: 'Registrar Compra',
                icon: Icons.save,
                isLoading: _isRegistering,
                onPressed: _registerPurchase,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    }

}