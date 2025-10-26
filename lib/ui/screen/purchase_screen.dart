// lib/ui/screen/purchase_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Importa tus modelos reales
import 'package:sicv_flutter/models/category.dart';
import 'package:sicv_flutter/models/product.dart';
import 'package:sicv_flutter/models/purchase_detail.dart';
import 'package:sicv_flutter/models/supplier.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => PurchaseScreenState();
}

class PurchaseScreenState extends State<PurchaseScreen> {
  // --- ESTADO DE LA ORDEN DE COMPRA ---
  
  // Proveedor seleccionado
  Supplier? _selectedSupplier;

  // Listas "maestras" (vendrían de tu API)
  List<Supplier> _allSuppliers = [];
  List<Product> _allProducts = [];

  // El "carrito" de la compra. Usamos la helper class.
  final List<PurchaseDetail> _purchaseItems = [];

  // El costo total de la orden
  double _totalCost = 0.0;

  // --- CONTROLADORES ---
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
    }
    super.dispose();
  }

  /// Carga los datos maestros (simulación de API)
  void _loadData() {
    // SIMULACIÓN DE PROVEEDORES
    _allSuppliers = [
      Supplier(id: 1, name: 'Coca-Cola FEMSA'),
      Supplier(id: 2, name: 'Alimentos PAN'),
      Supplier(id: 3, name: 'Cigarrera Bigott'),
      Supplier(id: 4, name: 'Proveedor General'), // Añadido
    ];

    // SIMULACIÓN DE PRODUCTOS
    _allProducts = [
      // --- CAMBIO AQUÍ ---
      Product(id: 1, name: 'Harina PAN', description: '...', price: 1.40, stock: 50, category: Category(id: 1, name: 'Alimentos'), sku: 'ALI-001'),
      Product(id: 2, name: 'Cigarros Marlboro', description: '...', price: 5.99, stock: 5, category: Category(id: 2, name: 'Tabaco'), sku: 'TAB-001'),
      Product(id: 3, name: 'Café', description: '...', price: 10.99, stock: 0, category: Category(id: 3, name: 'Bebidas'), sku: 'BEB-001'),
      Product(id: 4, name: 'Gaseosa 2L', description: '...', price: 2.5, stock: 50, category: Category(id: 3, name: 'Bebidas'), sku: 'BEB-002'),
      Product(id: 5, name: 'Pan Campesino', description: '...', price: 2.0, stock: 15, category: Category(id: 1, name: 'Alimentos'), sku: 'ALI-002'),
      Product(id: 6, name: 'Agua Minalba 1L', description: '...', price: 1.0, stock: 30, category: Category(id: 3, name: 'Bebidas'), sku: 'BEB-003'),
    ];

    // Inicialmente no hay nada seleccionado
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
  void _addProductToPurchase(Product product) {
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
    final costController = TextEditingController(text: product.price.toStringAsFixed(2));

    // Añade listeners para que el total se actualice automáticamente
    quantityController.addListener(_updateTotalCost);
    costController.addListener(_updateTotalCost);

    final newItem = PurchaseDetail(
      product: product,
      quantityController: quantityController,
      costController: costController,
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

    setState(() {
      _purchaseItems.removeAt(index);
    });
    _updateTotalCost(); // Actualiza el total
  }

  /// Guarda la compra (lógica final)
  void _registerPurchase() {
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un proveedor.')),
      );
      return;
    }
    if (_purchaseItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No has añadido productos a la orden.')),
      );
      return;
    }

    // AQUÍ VA TU LÓGICA DE API/BD
    // 1. Obtén el supplierId: _selectedSupplier!.id
    // 2. Obtén el total: _totalCost
    // 3. Itera sobre _purchaseItems para obtener la lista de productos:
    //    _purchaseItems.map((item) => {
    //        "productId": item.product.id,
    //        "quantity": int.tryParse(item.quantityController.text) ?? 0,
    //        "cost": double.tryParse(item.costController.text) ?? 0.0,
    //    }).toList()
    // 4. Envía esto a tu backend Node.js
    // 5. Si tiene éxito, limpia la pantalla y muestra un mensaje.

    print('Registrando compra del proveedor: ${_selectedSupplier!.name}');
    print('Total: \$$_totalCost');
    print('Items: ${_purchaseItems.length}');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Compra registrada exitosamente (simulación)'),
        backgroundColor: Colors.green,
      ),
    );

    // Limpia la pantalla para una nueva orden
    setState(() {
      _purchaseItems.clear();
      _selectedSupplier = null;
      _totalCost = 0.0;
    });
  }

  /// Muestra el modal para buscar y añadir productos
  void showProductSearchModal() {
    // Filtra los productos que pertenecen al proveedor seleccionado
    // OJO: Si _selectedSupplier es null, la lista estará vacía (¡bien!)
    List<Product> supplierProducts = _allProducts;
    
    // Lista filtrada para la búsqueda dentro del modal
    List<Product> filteredProducts = supplierProducts;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que el modal sea de pantalla completa
      builder: (ctx) {
        // Usamos StatefulBuilder para que el modal maneje su propio estado de búsqueda
        return StatefulBuilder(
          builder: (modalContext, modalSetState) {
            void filterModalList(String query) {
              modalSetState(() {
                if (query.isEmpty) {
                  filteredProducts = supplierProducts;
                } else {
                  filteredProducts = supplierProducts
                      .where((p) =>
                          p.name.toLowerCase().contains(query.toLowerCase()) ||
                          (p.sku ?? '').toLowerCase().contains(query.toLowerCase()))
                      .toList();
                }
              });
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.8, // 80% de la pantalla
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Añadir Producto a la Orden', // Título genérico
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: filterModalList,
                    decoration: InputDecoration(
                      labelText: 'Buscar producto por nombre o SKU',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        // Revisa si ya está en la orden principal
                        final bool isAlreadyAdded = _purchaseItems
                            .any((item) => item.product.id == product.id);

                        return Card(
                          color: isAlreadyAdded ? Colors.grey[300] : null,
                          child: ListTile(
                            title: Text(product.name),
                            subtitle: Text('Stock actual: ${product.stock}'),
                            trailing: isAlreadyAdded ? Icon(Icons.check, color: Colors.green) : Icon(Icons.add),
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
    ).whenComplete(() => _searchController.clear()); // Limpia el buscador al cerrar el modal
  }

  // --- CONSTRUCCIÓN DE LA UI ---

  @override
  Widget build(BuildContext context) {
    /*return Scaffold(
      //appBar: AppBar( // (También quitaremos esto en el Paso 2)
      //  title: const Text('Registrar Nueva Compra'),
      //),
      floatingActionButton: FloatingActionButton(
        onPressed: _showProductSearchModal,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSupplierSelector(),
            const SizedBox(height: 16),
            const Divider(),
            _buildProductList(), // Este es el Expanded()
            
            // --- LO PEGAMOS AQUÍ ---
            // Ya no ocupa toda la pantalla, respetará el Padding
            _buildSummaryAndSave(), 
          ],
        ),
      ),
      // --- YA NO HAY bottomNavigationBar ---
    );*/
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSupplierSelector(),
          const SizedBox(height: 16),
          const Divider(),
          _buildProductList(), // Este es el Expanded()
          
          // El resumen ahora usará la versión corregida de la Parte 1
          _buildSummaryAndSave(), 
        ],
      ),
    );
  }

  /// El Dropdown para seleccionar el proveedor
  Widget _buildSupplierSelector() {
    return DropdownButtonFormField<Supplier>(
      initialValue: _selectedSupplier,
      hint: const Text('Selecciona un Proveedor...'),
      decoration: InputDecoration(
        labelText: 'Proveedor',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.store),
      ),
      items: _allSuppliers.map((supplier) {
        return DropdownMenuItem(
          value: supplier,
          child: Text(supplier.name),
        );
      }).toList(),
      onChanged: (Supplier? newValue) {
        setState(() {
          // Si el proveedor cambia, limpiamos la orden
          setState(() {
          _selectedSupplier = newValue;
        });
          _selectedSupplier = newValue;
        });
      },
    );
  }

  /// La lista expandible de productos añadidos
  Widget _buildProductList() {
    if (_purchaseItems.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            // Mensaje simplificado.
            'Añade productos a la orden usando el botón (+).',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Si hay items, muestra la lista
    return Expanded(
      child: ListView.builder(
        itemCount: _purchaseItems.length,
        itemBuilder: (context, index) {
          final item = _purchaseItems[index];
          return _buildPurchaseItemTile(item, index);
        },
      ),
    );
  }

  /// La tarjeta individual para cada item en la lista
  Widget _buildPurchaseItemTile(PurchaseDetail item, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              title: Text(item.product.name),
              subtitle: Text(item.product.sku ?? 'Sin SKU'),
              trailing: IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red[700]),
                onPressed: () => _removeItem(index),
              ),
            ),
            // Fila para Cantidad y Costo
            Row(
              children: [
                // Campo de Cantidad
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: item.quantityController,
                    decoration: InputDecoration(
                      labelText: 'Cantidad',
                      prefixIcon: Icon(Icons.inventory_2_outlined, size: 20),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 8),
                // Campo de Costo
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: item.costController,
                    decoration: InputDecoration(
                      labelText: 'Costo por Unidad',
                      prefixIcon: Icon(Icons.attach_money, size: 20),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// La barra inferior que muestra el total y el botón de Guardar
  Widget _buildSummaryAndSave() {
    return Container(
      padding: const EdgeInsets.only(top: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        // --- 1. CAMBIO: Centra TODO en la columna ---
        crossAxisAlignment: CrossAxisAlignment.center, 
        children: [
          // Resumen de Total
          // Como el Column centra, este Row necesita ocupar todo el ancho
          // para que spaceBetween funcione. Padding lo fuerza.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Añade padding horizontal al Row
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TOTAL DE LA ORDEN:', style: Theme.of(context).textTheme.titleMedium),
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

          // --- 2. CAMBIO: El botón ahora está DIRECTAMENTE en el Column ---
          // Como el Column tiene crossAxisAlignment: center, el botón se centrará
          // y tomará su tamaño natural.
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Registrar Compra'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: _registerPurchase,
          ),
          // --- FIN DEL CAMBIO ---

          const SizedBox(height: 16), // Espacio al final
        ],
      ),
    );
  }
}