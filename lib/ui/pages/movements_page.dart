// lib/ui/screen/movements_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Importa tus modelos
import 'package:sicv_flutter/models/category.dart'; // Necesario para el modelo Product
import 'package:sicv_flutter/models/movement_type.dart';
import 'package:sicv_flutter/models/movement.dart'; // Asegúrate que este sea el nombre correcto
import 'package:sicv_flutter/models/product.dart';
import 'package:flutter/services.dart';
import 'package:sicv_flutter/ui/widgets/menu.dart';

class MovementsScreen extends StatefulWidget {
  const MovementsScreen({super.key});

  @override
  State<MovementsScreen> createState() => _MovementsScreenState();
}

class _MovementsScreenState extends State<MovementsScreen> {
  // --- Estado ---
  late List<StockMovement> _allMovements;
  late List<StockMovement> _filteredMovements;
  final TextEditingController _searchController = TextEditingController();

  // Filtros
  MovementType? _selectedMovementType;
  String _selectedDateRange = 'Últimos 7 días'; // Valor inicial
  final List<String> _dateRangeOptions = [
    'Hoy', 'Ayer', 'Últimos 7 días', 'Este mes', 'Todos'
  ];

  // --- ¡IMPORTANTE! Mueve la lista de productos aquí ---
  // Esta lista (_allProducts) debe estar disponible para el diálogo
  // Asegúrate de que esta lista se cargue/actualice correctamente desde tu API
  late List<Product> _allProducts;


  @override
  void initState() {
    super.initState();
    // Primero carga los productos (necesario para el diálogo)
    _loadProducts(); // Función separada para productos
    // Luego carga los movimientos
    _loadMovements(); // Función separada para movimientos
    _searchController.addListener(_runFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Carga productos (simulación)
  void _loadProducts() {
    // --- SIMULACIÓN DE PRODUCTOS ---
     _allProducts = [
      Product(id: 1, name: 'Harina PAN', description: '...', price: 1.40, stock: 50, category: Category(id: 1, name: 'Alimentos'), sku: 'ALI-001'),
      Product(id: 2, name: 'Cigarros Marlboro', description: '...', price: 5.99, stock: 5, category: Category(id: 2, name: 'Tabaco'), sku: 'TAB-001'),
      Product(id: 3, name: 'Café', description: '...', price: 10.99, stock: 0, category: Category(id: 3, name: 'Bebidas'), sku: 'BEB-001'),
      Product(id: 4, name: 'Gaseosa 2L', description: '...', price: 2.5, stock: 50, category: Category(id: 3, name: 'Bebidas'), sku: 'BEB-002'),
      Product(id: 5, name: 'Pan Campesino', description: '...', price: 2.0, stock: 15, category: Category(id: 1, name: 'Alimentos'), sku: 'ALI-002'),
      Product(id: 6, name: 'Agua Minalba 1L', description: '...', price: 1.0, stock: 30, category: Category(id: 3, name: 'Bebidas'), sku: 'BEB-003'),
    ];
    // --- FIN SIMULACIÓN ---

    // Llama a setState si esta carga fuera asíncrona
    // setState((){});
  }


  // Carga movimientos (simulación)
  void _loadMovements() {
    // --- SIMULACIÓN DE DATOS (Reemplaza con tu API) ---
    final now = DateTime.now();
    _allMovements = [
      StockMovement(dateTime: now.subtract(const Duration(hours: 1)), productName: 'Harina PAN', productSku: 'ALI-001', movementType: MovementType.venta, quantity: -2, stockBefore: 52, stockAfter: 50, userName: 'Vendedor1', referenceId: 'VTA-101'),
      StockMovement(dateTime: now.subtract(const Duration(hours: 3)), productName: 'Gaseosa 2L', productSku: 'BEB-002', movementType: MovementType.compra, quantity: 24, stockBefore: 26, stockAfter: 50, userName: 'Admin', referenceId: 'CMP-050'),
      StockMovement(dateTime: now.subtract(const Duration(days: 1)), productName: 'Cigarros Marlboro', productSku: 'TAB-001', movementType: MovementType.venta, quantity: -1, stockBefore: 6, stockAfter: 5, userName: 'Vendedor1', referenceId: 'VTA-100'),
      StockMovement(dateTime: now.subtract(const Duration(days: 2)), productName: 'Harina PAN', productSku: 'ALI-001', movementType: MovementType.compra, quantity: 50, stockBefore: 2, stockAfter: 52, userName: 'Admin', referenceId: 'CMP-048'),
      StockMovement(dateTime: now.subtract(const Duration(days: 3)), productName: 'Café', productSku: 'BEB-001', movementType: MovementType.ajusteNegativo, quantity: -1, stockBefore: 1, stockAfter: 0, userName: 'Admin', referenceId: 'Ajuste por daño'),
      StockMovement(dateTime: now.subtract(const Duration(days: 8)), productName: 'Gaseosa 2L', productSku: 'BEB-002', movementType: MovementType.venta, quantity: -4, stockBefore: 30, stockAfter: 26, userName: 'Vendedor2', referenceId: 'VTA-095'),
    ];
    _allMovements.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    _filteredMovements = _allMovements;
    _runFilter(); // Aplica filtros iniciales
    // --- FIN SIMULACIÓN ---
  }

  void _runFilter() {
     // Verifica que _allMovements no sea null antes de usarla
    List<StockMovement> results = _allMovements;
    String searchText = _searchController.text.toLowerCase();
    final now = DateTime.now();
    DateTime startDate;

    // 1. Filtrar por Rango de Fechas
    switch (_selectedDateRange) {
      case 'Hoy':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Ayer':
        final yesterday = now.subtract(const Duration(days: 1));
        startDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
        results = results.where((m) =>
          m.dateTime.isAfter(startDate) &&
          m.dateTime.isBefore(DateTime(now.year, now.month, now.day))
        ).toList();
        break;
      case 'Últimos 7 días':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'Este mes':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Todos':
      default:
        startDate = DateTime(2000);
        break;
    }

    if (_selectedDateRange != 'Ayer') {
        results = results.where((m) => m.dateTime.isAfter(startDate)).toList();
    }

    // 2. Filtrar por Tipo de Movimiento
    if (_selectedMovementType != null) {
      results = results
          .where((m) => m.movementType == _selectedMovementType)
          .toList();
    }

    // 3. Filtrar por Texto de Búsqueda
    if (searchText.isNotEmpty) {
      results = results
          .where((m) =>
              m.productName.toLowerCase().contains(searchText) ||
              (m.productSku ?? '').toLowerCase().contains(searchText))
          .toList();
    }

    setState(() {
      _filteredMovements = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Movimientos'),
      ),
      body: Column(
        children: [
          // Buscador y Filtros (sin cambios)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration( /*...*/ ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 12.0, runSpacing: 8.0,
              children: [
                _buildDateRangeFilter(),
                _buildMovementTypeFilter(),
              ],
            ),
          ),
          const Divider(height: 24),

          // Lista/Tabla
          Expanded(
            // Empieza directamente comprobando si está vacía
            child: _filteredMovements.isEmpty
                    ? const Center(child: Text('No se encontraron movimientos.'))
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          bool isDesktop = constraints.maxWidth > 700;
                          return isDesktop
                              ? _buildMovementsDataTable()
                              : _buildMovementsListView();
                        },
                      ),
          ),
        ],
      ),
      drawer: const Menu(),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Ajuste Manual'),
        onPressed: () => _showAddMovementDialog(context),
      ),
    );
  }

  // --- Dropdowns (_buildDateRangeFilter, _buildMovementTypeFilter) ---

  /// Dropdown para filtro de Rango de Fechas
  Widget _buildDateRangeFilter() {
    return DropdownButton<String>(
      value: _selectedDateRange,
      items: _dateRangeOptions.map((range) {
        return DropdownMenuItem(value: range, child: Text(range));
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedDateRange = newValue;
          });
          _runFilter(); // Llama al filtro
        }
      },
      hint: const Text('Periodo'),
      underline: Container(), // Quita la línea de abajo para un look más limpio
    );
  }

  /// Dropdown para filtro de Tipo de Movimiento
  Widget _buildMovementTypeFilter() {
    return DropdownButton<MovementType>(
      value: _selectedMovementType,
      items: [
        // Opción para quitar el filtro ("Todos")
        const DropdownMenuItem(value: null, child: Text('Todos los tipos')),
        // Genera las opciones desde el enum MovementType
        ...MovementType.values.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Row(
              mainAxisSize: MainAxisSize.min, // Para que el Row no sea muy ancho
              children: [
                Icon(type.icon, color: type.color, size: 18), // Muestra ícono y color
                const SizedBox(width: 8),
                Text(type.displayName), // Muestra el nombre legible
              ],
            ),
          );
        })
      ],
      onChanged: (MovementType? newValue) {
        setState(() {
          _selectedMovementType = newValue; // Puede ser null si selecciona "Todos"
        });
        _runFilter(); // Llama al filtro
      },
      hint: const Text('Tipo'),
      underline: Container(), // Quita la línea de abajo
    );
  }

  // --- DataTable y ListView (_buildMovementsDataTable, _buildMovementsListView) ---

  /// Vista de Tabla para PC
  Widget _buildMovementsDataTable() {
    // Define el formato de fecha una sola vez
    final dateFormat = DateFormat('dd/MM/yy HH:mm');

    // Usa SingleChildScrollView para permitir scroll horizontal si la tabla es muy ancha
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        // Define las columnas de la tabla
        columns: const [
          DataColumn(label: Text('Fecha y Hora')),
          DataColumn(label: Text('Producto')),
          DataColumn(label: Text('Tipo')),
          DataColumn(label: Text('Cant.'), numeric: true), // 'numeric' alinea a la derecha
          DataColumn(label: Text('Stock Ant.'), numeric: true),
          DataColumn(label: Text('Stock Desp.'), numeric: true),
          DataColumn(label: Text('Usuario')),
          DataColumn(label: Text('Referencia')),
        ],
        // Genera las filas a partir de la lista filtrada
        rows: _filteredMovements.map((movement) {
          // Determina el color y prefijo de la cantidad
          final qtyColor = movement.quantity >= 0 ? Colors.green.shade700 : Colors.red.shade700;
          final qtyPrefix = movement.quantity > 0 ? '+' : ''; // Solo '+' si es positivo

          return DataRow(cells: [
            DataCell(Text(dateFormat.format(movement.dateTime))), // Fecha formateada
            DataCell(
              Tooltip( // Añade Tooltip si el nombre es largo
                message: '${movement.productName}\nSKU: ${movement.productSku ?? 'N/A'}',
                child: Text(movement.productName, overflow: TextOverflow.ellipsis),
              )
            ),
            DataCell(Row(children: [ // Muestra ícono y nombre del tipo
              Icon(movement.movementType.icon, color: movement.movementType.color, size: 16),
              const SizedBox(width: 4),
              Text(movement.movementType.displayName),
            ])),
            DataCell(Text( // Cantidad con color y signo
              qtyPrefix + movement.quantity.toString(),
              style: TextStyle(color: qtyColor, fontWeight: FontWeight.bold),
            )),
            DataCell(Text(movement.stockBefore.toString())), // Stock antes
            DataCell(Text(movement.stockAfter.toString())), // Stock después
            DataCell(Text(movement.userName)), // Usuario
            DataCell(
              Tooltip( // Tooltip para referencias largas
                message: movement.referenceId ?? '-',
                child: Text(movement.referenceId ?? '-', overflow: TextOverflow.ellipsis),
              )
            ), // Referencia
          ]);
        }).toList(),
      ),
    );
  }

  /// Vista de Lista para Móvil
  Widget _buildMovementsListView() {
    // Define el formato de fecha
    final dateFormat = DateFormat('dd/MM/yy HH:mm');

    return ListView.builder(
      itemCount: _filteredMovements.length,
      itemBuilder: (context, index) {
        final movement = _filteredMovements[index];
        // Determina color y prefijo de cantidad
        final qtyColor = movement.quantity >= 0 ? Colors.green.shade700 : Colors.red.shade700;
        final qtyPrefix = movement.quantity >= 0 ? '+' : '';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: ListTile(
            leading: Tooltip( // Tooltip para el tipo de movimiento
              message: movement.movementType.displayName,
              child: Icon(movement.movementType.icon, color: movement.movementType.color),
            ),
            title: Text(
              '${movement.productName} (${movement.productSku ?? 'N/A'})',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
                '${dateFormat.format(movement.dateTime)} - ${movement.userName}\n' // Fecha y usuario
                'Ref: ${movement.referenceId ?? '-'} | Stock: ${movement.stockBefore} -> ${movement.stockAfter}' // Referencia y cambio de stock
            ),
            trailing: Text( // Cantidad al final
              qtyPrefix + movement.quantity.toString(),
              style: TextStyle(
                color: qtyColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            isThreeLine: true, // Da más espacio vertical al ListTile
          ),
        );
      },
    );
  }


  // --- Diálogo _showAddMovementDialog ---
  void _showAddMovementDialog(BuildContext context) {
    // Controladores para el formulario del diálogo (sin underscore)
    final productController = TextEditingController(); // <-- No underscore
    final quantityController = TextEditingController(); // <-- No underscore
    final reasonController = TextEditingController(); // <-- No underscore
    MovementType selectedAdjustmentType = MovementType.ajustePositivo; // <-- No underscore
    Product? selectedProduct; // <-- No underscore

    // --- CORRECCIÓN AQUÍ: Usa la lista _allProducts inicializada ---
    // Si _allProducts es null, usa una lista vacía para evitar el error .map
    final List<Product> productsForSelection = _allProducts;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Registrar Ajuste Manual'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    DropdownButtonFormField<Product>(
                      initialValue: selectedProduct,
                      hint: const Text('Selecciona Producto...'),
                      isExpanded: true,
                      // --- VERIFICACIÓN ADICIONAL ---
                      items: productsForSelection.isEmpty
                          ? [const DropdownMenuItem(child: Text("Cargando productos..."))] // Muestra mensaje si está vacío
                          : productsForSelection.map((product) {
                              return DropdownMenuItem(
                                value: product,
                                child: Text(product.name, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                      onChanged: productsForSelection.isEmpty ? null : (Product? newValue) { // Deshabilita si no hay productos
                        setStateDialog(() {
                          selectedProduct = newValue;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Producto'),
                    ),
                    const SizedBox(height: 16),
                    // --- Selector de Tipo de Ajuste ---
                    DropdownButtonFormField<MovementType>(
                      initialValue: selectedAdjustmentType,
                      items: [ // Solo muestra tipos de AJUSTE
                        DropdownMenuItem(
                          value: MovementType.ajustePositivo,
                          child: Row(children: [
                            Icon(MovementType.ajustePositivo.icon, color: MovementType.ajustePositivo.color, size: 18), // Icono y color
                            const SizedBox(width: 8),
                            Text(MovementType.ajustePositivo.displayName) // Nombre legible
                          ])
                        ),
                        DropdownMenuItem(
                          value: MovementType.ajusteNegativo,
                          child: Row(children: [
                            Icon(MovementType.ajusteNegativo.icon, color: MovementType.ajusteNegativo.color, size: 18), // Icono y color
                            const SizedBox(width: 8),
                            Text(MovementType.ajusteNegativo.displayName) // Nombre legible
                          ])
                        ),
                      ],
                      onChanged: (MovementType? newValue) {
                        // Actualiza el estado DENTRO del diálogo cuando cambia la selección
                        if (newValue != null) {
                          setStateDialog(() { // Usa el setState del StatefulBuilder
                            selectedAdjustmentType = newValue;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Ajuste',
                        border: OutlineInputBorder(), // Añade un borde
                      ),
                    ),
                    const SizedBox(height: 16),
                    // --- Campo de Cantidad ---
                    TextField(
                      controller: quantityController, // Usa el controlador definido
                      decoration: const InputDecoration(
                        labelText: 'Cantidad (Positivo)',
                        hintText: 'Ej: 5',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers), // Icono opcional
                      ),
                      keyboardType: TextInputType.number, // Muestra teclado numérico
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly // Solo permite números enteros positivos
                      ],
                    ),
                    const SizedBox(height: 16),
                    // --- Campo de Razón (Opcional) ---
                    TextField(
                      controller: reasonController, // Usa el controlador definido
                      decoration: const InputDecoration(
                        labelText: 'Razón del ajuste (Opcional)',
                        hintText: 'Ej: Mercancía dañada, Conteo de inventario',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2, // Permite escribir un poco más
                      textCapitalization: TextCapitalization.sentences, // Empieza frases con mayúscula
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                ElevatedButton(
                  child: const Text('Guardar Ajuste'),
                  onPressed: () {
                    // --- Lógica de guardado (sin cambios, pero verifica product.stock) ---
                    final product = selectedProduct;
                    // ... (resto de tu lógica de validación y guardado)
                     if (product == null || quantityController.text.isEmpty) { /* ... */ return;}
                     final quantity = int.tryParse(quantityController.text);
                     if (quantity == null || quantity <= 0) { /* ... */ return;}

                     final int signedQuantity = (selectedAdjustmentType == MovementType.ajustePositivo) ? quantity : -quantity;

                     // --- ¡IMPORTANTE OBTENER STOCK ACTUAL REAL! ---
                     // Busca el producto en la lista _allProducts para obtener el stock MÁS RECIENTE
                     // (Idealmente, harías una llamada a la API aquí)
                     final currentProductData = _allProducts.firstWhere((p) => p.id == product.id, orElse: () => product); // Fallback al producto seleccionado si no se encuentra
                     final int currentStock = currentProductData.stock;
                     final int stockAfter = currentStock + signedQuantity;

                     if (stockAfter < 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text('Ajuste inválido. El stock no puede ser negativo (quedaría en $stockAfter).'), backgroundColor: Colors.red),
                        );
                        return; // No permite stock negativo
                     }


                     final newMovement = StockMovement(
                       dateTime: DateTime.now(),
                       productName: product.name, // Ya validamos que no es null
                       productSku: product.sku,
                       movementType: selectedAdjustmentType,
                       quantity: signedQuantity,
                       stockBefore: currentStock,
                       stockAfter: stockAfter,
                       userName: 'UsuarioActual', // Reemplaza
                       referenceId: reasonController.text.isNotEmpty ? reasonController.text : 'Ajuste manual',
                     );

                    // --- LLAMADA A API Y ACTUALIZACIÓN LOCAL ---
                    // (Tu lógica de simulación/API va aquí)
                     setState(() {
                       _allMovements.insert(0, newMovement);
                       // Actualiza el stock en la lista _allProducts (simulación)
                       final productIndex = _allProducts.indexWhere((p) => p.id == product.id);
                       if (productIndex != -1) {
                         // Crea un NUEVO objeto Product con el stock actualizado
                         _allProducts[productIndex] = Product(
                            id: _allProducts[productIndex].id,
                            name: _allProducts[productIndex].name,
                            description: _allProducts[productIndex].description,
                            price: _allProducts[productIndex].price,
                            stock: stockAfter, // Stock actualizado
                            category: _allProducts[productIndex].category,
                            sku: _allProducts[productIndex].sku,
                            imageUrl: _allProducts[productIndex].imageUrl
                         );
                         print("Stock simulado actualizado para ${product.name}: $stockAfter");
                       }
                       _runFilter();
                     });

                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ajuste guardado exitosamente.'), // Mensaje de confirmación
                      backgroundColor: Colors.green, // Color verde para indicar éxito
                      duration: Duration(seconds: 2), // Duración opcional
                    ),
                  );
                  },
                ),
              ],
            );
          }
        );
      },
    ).whenComplete(() {
      productController.dispose();
      quantityController.dispose();
      reasonController.dispose();
    });
  }

} // Fin de _MovementsScreenState