import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/models/category_model.dart';
import 'package:sicv_flutter/models/depot_model.dart';
import 'package:sicv_flutter/models/product_model.dart';
import 'package:sicv_flutter/models/provider_model.dart';
import 'package:sicv_flutter/models/purchase_detail.dart';
import 'package:sicv_flutter/models/purchase_input_model.dart';
import 'package:sicv_flutter/models/purchase_item_input_model.dart';
import 'package:sicv_flutter/models/purchase_model.dart';
import 'package:sicv_flutter/services/depot_service.dart';
import 'package:sicv_flutter/services/product_service.dart';
import 'package:sicv_flutter/services/provider_service.dart';
import 'package:sicv_flutter/services/purchase_service.dart';
import 'package:sicv_flutter/ui/widgets/atomic/button_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/drop_down_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/text_field_app.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => PurchaseScreenState();
}

class PurchaseScreenState extends State<PurchaseScreen> {
  final ProviderService _providerService = ProviderService();
  final ProductService _productService = ProductService();
  final DepotService _depotService = DepotService();
  final PurchaseService _purchaseService = PurchaseService();
  late List<ProviderModel> _allProviders = [];

  ProviderModel? _selectedProvider;

  List<ProductModel> _allProducts = [];
  bool _isRegistering = false;

  // El "carrito" de la compra. Usamos la helper class.
  final List<PurchaseDetail> _purchaseItems = [];
  late List<DepotModel> _allDepots = [];

  // El costo total de la orden
  double _totalCost = 0.0;

  // Controlador para el modal de búsqueda
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    // Es MUY importante limpiar los controllers para evitar fugas de memoria
    _searchController.dispose();
    for (var item in _purchaseItems) {
      item.quantityController.dispose();
      item.costController.dispose();
      item.expirationDateController?.dispose();
    }
    super.dispose();
  }

  /// Carga los datos maestros (simulación de API)
  void _loadData() async {
    // SIMULACIÓN DE PRODUCTOS
    _allProducts = await _productService.getAll();
    _allProviders = await _providerService.getAllProviders();
    _allDepots = await _depotService.getDepots();
    setState(() {});
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

    DepotModel? initialDepot = (_allDepots.isNotEmpty) ? _allDepots.first : null;

    TextEditingController? expirationDateController;

    if(product.perishable) {
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

  /// Guarda la compra (lógica final)
  void _registerPurchase() async {
    setState(() => _isRegistering = true);
    if (_selectedProvider == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un proveedor.')),
      );
      setState(() => _isRegistering = false);
      return;
    }
    if (_purchaseItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No has añadido productos a la orden.')),
      );
      setState(() => _isRegistering = false);
      return;
    }

    final List<PurchaseItemInputModel> purchaseItemsList = [];

    for (var item in _purchaseItems) {
      final amount = int.tryParse(item.quantityController.text) ?? 0;
      final unitCost = double.tryParse(item.costController.text) ?? 0.0;

      final purchaseItem = PurchaseItemInputModel(
        productId: item.product.id, 
        depotId: item.selectedDepot!.depotId,
        amount: amount, 
        unitCost: unitCost,
        expirationDate: item.product.perishable && item.expirationDateController != null && item.expirationDateController!.text.isNotEmpty
        // 💡 Mejor usar DateTime.tryParse() para evitar errores si el formato es malo
        ? DateTime.tryParse(item.expirationDateController!.text)
        : null,
      );
      purchaseItemsList.add(purchaseItem);
    }

    final purchaseInput = PurchaseInputModel(
      providerId: _selectedProvider!.providerId,
      userCi: '31350493',
      status: 'Aprobado',
      typePaymentId: 1,
      items: purchaseItemsList,
    );

    try {

    final PurchaseModel response = await _purchaseService.createPurchase(purchaseInput);

    print(  'Compra registrada con ID: ${response.providerId}');

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar la compra: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isRegistering = false);
      return;
    }
    _searchController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Compra registrada exitosamente (simulación)'),
        backgroundColor: Colors.green,
      ),
    );

    // Limpia la pantalla para una nueva orden
    setState(() {
      _purchaseItems.clear();
      _selectedProvider = null;
      _totalCost = 0.0;
      _isRegistering = false;
    });
  }

  /// Muestra el modal para buscar y añadir productos
  void showProductSearchModal() {
    List<ProductModel> supplierProducts = _allProducts;

    // Lista filtrada para la búsqueda dentro del modal
    List<ProductModel> filteredProducts = supplierProducts;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
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
              height:
                  MediaQuery.of(context).size.height * 0.8, 
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Añadir Producto a la Orden',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: filterModalList,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                        fontSize:
                            14.0, 
                        color: AppColors
                            .textSecondary,
                      ),

                      filled: true,
                      fillColor: AppColors.secondary,
                      prefixIcon: Icon(Icons.search),
                      labelText: 'Buscar producto por nombre o SKU',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          width: 3.0, 
                          color: AppColors.border,
                        ),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          width:
                              3.0, 
                          color: AppColors
                              .textSecondary,
                        ),
                      ),
                    ),
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
                                ? null // No hacer nada si ya está añadido
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
    ).whenComplete(
      () => _searchController.clear(),
    ); // Limpia el buscador al cerrar el modal
  }

  /// El Dropdown para seleccionar el proveedor
  Widget _buildSupplierSelector() {
    return DropdownButtonFormField<ProviderModel>(
      initialValue: _selectedProvider,

      decoration: InputDecoration(
        labelStyle: TextStyle(
          fontSize: 14.0,
          color:
              AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.secondary,
        prefixIcon: Icon(Icons.store, size: 20),
        labelText: 'Proveedor',
        hintText: 'Selecciona un Proveedor...',
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            width: 3.0,
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            width: 3.0, 
            color: AppColors.textSecondary,
          ),
        ),
      ),
      items: _allProviders.map((supplier) {
        return DropdownMenuItem<ProviderModel>(
          value: supplier,
          child: Text(supplier.name),
        );
      }).toList(),

      onChanged: (ProviderModel? newValue) {
        setState(() {
          // Si el proveedor cambia, limpiamos la orden
          _selectedProvider = newValue;
          //_purchaseItems.clear();
          //_totalCost = 0.0;
        });
      },
    );
  }

  /// La lista expandible de productos añadidos
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
      constraints: const BoxConstraints(
        maxHeight: 600,
      ),
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

/// Construye el campo de fecha de vencimiento con el DatePicker
  Widget _buildExpirationDateField(TextEditingController? controller) {
    // Es crucial que el controlador no sea nulo antes de usarlo
    if (controller == null) return const SizedBox.shrink(); 

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 160,
        maxWidth: 160,
      ),
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
            firstDate: DateTime.now(), // No se pueden seleccionar fechas pasadas
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
      /*TextField(
        controller: controller,
        readOnly: true, // Importante: solo se selecciona tocando
        onTap: () async {
          // Implementación del DatePicker
          final DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(), // Fecha inicial
            firstDate: DateTime.now(), // No se pueden seleccionar fechas pasadas
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
        style: const TextStyle(fontSize: 14.0),
        decoration: const InputDecoration(
          labelText: 'F. Vencimiento',
          prefixIcon: Icon(Icons.calendar_today, size: 20),
          isDense: true,
          contentPadding:
              EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
          // ... (Añade tus estilos de borde aquí si es necesario) ...
        ),
      ),*/
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
      margin: const EdgeInsets.symmetric(
        vertical: 8.0,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            // Sección Superior: Nombre, SKU y Botón Eliminar
            ListTile(
              contentPadding:
                  EdgeInsets.zero,
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
                    onChanged:(newValue) {
                        setState(() {
                          item.selectedDepot = newValue;
                        });
                      } , 
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

  /// La barra inferior que muestra el total y el botón de Guardar
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
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
              ), 
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

  // --- CONSTRUCCIÓN DE LA UI ---
  @override
  Widget build(BuildContext context) {
    return Center(
      // Centra el contenido horizontalmente
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize
                      .min,
                  children: [
                    _buildSupplierSelector(),
                    const SizedBox(height: 16),
                    const Divider(),
                    _buildProductList(), // Esta función debe ser modificada (ver punto 2)
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            _buildSummaryAndSave(),
          ],
        ),
      ),
    );
  }
}
