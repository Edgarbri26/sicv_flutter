// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:sicv_flutter/models/category.dart';
import 'package:sicv_flutter/models/product.dart';

class InventoryDatatableScreen extends StatefulWidget {
  @override
  _InventoryDatatableScreenState createState() =>
      _InventoryDatatableScreenState();
}

class _InventoryDatatableScreenState extends State<InventoryDatatableScreen> {
  // --- DATOS DE EJEMPLO ---
  final Category catBebidas = Category(id: 1, name: 'Bebidas');
  final Category catLimpieza = Category(id: 2, name: 'Limpieza');
  final Category catAlimentos = Category(id: 3, name: 'Alimentos');
  final Category catPersonal = Category(id: 4, name: 'Cuidado Personal');
  
  late final List<Product> _allProducts;

  List<Product> _filteredProducts = [];

  // Estado para los filtros
  String _searchQuery = '';
  String _selectedCategory = 'Todas';
  final List<String> _categories = ['Todas', 'Bebidas', 'Limpieza', 'Alimentos', 'Personal'];

  int? _sortColumnIndex;      // Índice de la columna ordenada (null = ninguna)
  bool _sortAscending = true; // Dirección del orden (true = Ascendente)

  static const int _stockLowThreshold = 10;

  @override
  void initState() {
    super.initState();

    _allProducts = [
    Product(
        id: 1,
        name: 'Gaseosa 2L',
        description: 'Refresco sabor a cola de 2 litros.',
        price: 2.5,
        imageUrl: 'https://via.placeholder.com/150/FF0000/FFFFFF?text=Gaseosa',
        stock: 50,
        category: catBebidas,
        sku: 'GAS-001', // <-- ¡AÑADIDO!
      ),
      Product(
        id: 2,
        name: 'Jabón en Polvo 1kg',
        description: 'Detergente en polvo para ropa blanca y de color.',
        price: 4.0,
        imageUrl: 'https://via.placeholder.com/150/0000FF/FFFFFF?text=Jabon',
        stock: 8,
        category: catLimpieza,
        sku: 'LIM-001', // <-- ¡AÑADIDO!
      ),
      Product(
        id: 3,
        name: 'Arroz 1kg',
        description: 'Arroz blanco de grano largo tipo 1.',
        price: 1.2,
        imageUrl: 'https://via.placeholder.com/150/FFFF00/000000?text=Arroz',
        stock: 120,
        category: catAlimentos,
        sku: 'ALI-001', // <-- ¡AÑADIDO!
      ),
      Product(
        id: 4,
        name: 'Shampoo 500ml',
        description: 'Shampoo para cabello seco con aceite de argán.',
        price: 5.5,
        imageUrl: 'https://via.placeholder.com/150/00FF00/FFFFFF?text=Shampoo',
        stock: 0,
        category: catPersonal,
        sku: 'PER-001', // <-- ¡AÑADIDO!
      ),
      Product(
        id: 5,
        name: 'Agua Mineral 1.5L',
        description: 'Agua mineral de manantial sin gas.',
        price: 1.0,
        imageUrl: 'https://via.placeholder.com/150/00FFFF/000000?text=Agua',
        stock: 3,
        category: catBebidas,
        sku: 'GAS-002', // <-- ¡AÑADIDO!
      ),
      Product(
        id: 6,
        name: 'Lentejas 500g',
        description: 'Lentejas secas, fuente de proteína.',
        price: 0.9,
        imageUrl: 'https://via.placeholder.com/150/FFA500/FFFFFF?text=Lentejas',
        stock: 75,
        category: catAlimentos,
        sku: 'ALI-002', // <-- ¡AÑADIDO!
      ),
  ];
    _filteredProducts = _allProducts;
  }

  /// Filtra la lista de productos basado en la búsqueda y categoría
  // *** ¡REEMPLAZA TU MÉTODO _filterProducts CON ESTE! ***

  /// Filtra Y ORDENA la lista de productos
  void _filterProducts() {
    setState(() {
      List<Product> tempProducts = _allProducts;

      // 1. Filtrar por Categoría (igual que antes)
      if (_selectedCategory != 'Todas') {
        tempProducts = tempProducts
            .where((product) => product.category.name == _selectedCategory)
            .toList();
      }

      // 2. Filtrar por Búsqueda (igual que antes)
      if (_searchQuery.isNotEmpty) {
        tempProducts = tempProducts
            .where((product) =>
                product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                product.sku!.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();
      }

      // 3. Aplicar Ordenamiento
      if (_sortColumnIndex != null) {
        tempProducts.sort((a, b) {
          dynamic aValue;
          dynamic bValue;

          // *** ¡LOS ÍNDICES AQUÍ CAMBIARON! ***
          switch (_sortColumnIndex) {
            case 0: // Img
              return 0; // No se ordena por imagen
            case 1: // Producto (Nombre)
              aValue = a.name.toLowerCase();
              bValue = b.name.toLowerCase();
              break;
            case 2: // SKU
              aValue = a.sku!.toLowerCase();
              bValue = b.sku!.toLowerCase();
              break;
            case 3: // Categoría
              aValue = a.category.name.toLowerCase();
              bValue = b.category.name.toLowerCase();
              break;
            case 4: // Stock
              aValue = a.stock;
              bValue = b.stock;
              break;
            case 5: // Precio
              aValue = a.price;
              bValue = b.price;
              break;
            default:
              return 0; // No ordenar (para 'Acciones', etc.)
          }

          final comparison = aValue.compareTo(bValue);
          return _sortAscending ? comparison : -comparison;
        });
      }

      _filteredProducts = tempProducts;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usamos SingleChildScrollView para que toda la pantalla
    // pueda hacer scroll si el contenido es muy alto.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Alinear todo a la izquierda
        children: [
          _buildKpiDashboard(),
          SizedBox(height: 16),
          _buildFiltersAndSearch(),
          SizedBox(height: 16),
          // El DataTable debe estar envuelto para permitir
          // scroll horizontal si las columnas son muy anchas.
          SizedBox(
            width: double.infinity, // Ocupa todo el ancho posible
            child: Card(
              clipBehavior: Clip.antiAlias, // Evita que la tabla se salga
              
              // *** CAMBIO AQUÍ (Inicio) ***
              // 1. Usamos LayoutBuilder para obtener el ancho del padre (la Card)
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // 2. Mantenemos el SingleChildScrollView para el scroll
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    // 3. Usamos ConstrainedBox para forzar el ancho mínimo
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        // 4. El ancho mínimo de la tabla será el ancho máximo del padre
                        minWidth: constraints.maxWidth,
                      ),
                      child: _buildDataTable(),
                    ),
                  );
                },
              ),
              // *** CAMBIO AQUÍ (Fin) ***
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el "Dashboard" superior con KPIs (Valores clave)
  Widget _buildKpiDashboard() {
    double totalValue = _allProducts.fold(0, (sum, item) => sum + (item.price * item.stock));
    int lowStockItems = _allProducts.where((p) => p.stock > 0 && p.stock <= _stockLowThreshold).length;
    // Añadí el contador de Agotados que tenías en el código anterior
    int outOfStockItems = _allProducts.where((p) => p.stock == 0).length;


    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          
          // Ajusta este valor si lo necesitas
          bool isWideScreen = constraints.maxWidth > 600; 

          if (isWideScreen) {
            // --- VISTA ANCHA: (3 en fila) ---
            return Row(
              children: [
                Expanded(
                  flex: 2, // Más espacio para el valor total
                  child: _buildKpiCard('Valor Total (Precio)', '\$${totalValue.toStringAsFixed(2)}', Colors.blue.shade800),
                ),
                SizedBox(width: 8), // Reduje el espacio
                Expanded(
                  flex: 1,
                  child: _buildKpiCard('Items (SKUs)', _allProducts.length.toString(), Colors.green.shade800), 
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: _buildKpiCard('Stock Bajo', lowStockItems.toString(), Colors.orange.shade800), 
                ),
              ],
            );
          } else {
            // --- VISTA ANGOSTA: (2 en fila, 1 abajo) ---
            return Column(
              children: [
                // Fila 1: Dos tarjetas
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard('Items (SKUs)', _allProducts.length.toString(), Colors.green.shade800)
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _buildKpiCard('Stock Bajo', lowStockItems.toString(), Colors.orange.shade800)
                    ),
                  ],
                ),
                SizedBox(height: 8), // Espacio entre filas
                
                // Fila 2: Una tarjeta (al estar sola en un Row+Expanded, ocupa todo el ancho)
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard('Valor Total (Precio)', '\$${totalValue.toStringAsFixed(2)}', Colors.blue.shade800)
                    ),
                  ],
                ),
                
                // (Opcional: Si también quieres mostrar "Agotados")
                // SizedBox(height: 8),
                // Row(
                //   children: [
                //     Expanded(
                //       child: _buildKpiCard('Agotados', outOfStockItems.toString(), Colors.red.shade800)
                //     ),
                //   ],
                // ),

              ],
            );
          }
        },
      ),
    );
  }

  /// Widget helper para una tarjeta de KPI
  Widget _buildKpiCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      // ignore: deprecated_member_use
      color: color.withOpacity(0.1),
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
                  color: color),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la barra de búsqueda, filtro y botón de añadir (RESPONSIVO)
  Widget _buildFiltersAndSearch() {
    return Column(
      children: [
        
        // *** ¡AQUÍ ESTÁ LA MAGIA! ***
        // LayoutBuilder nos da el ancho disponible
        LayoutBuilder(
          builder: (context, constraints) {
            
            // Define un "punto de quiebre". 600px es un buen estándar
            // (la mayoría de los teléfonos en vertical son < 600px)
            bool isWideScreen = constraints.maxWidth > 600;

            if (isWideScreen) {
              // --- VISTA ANCHA: Usa un Row ---
              return Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildSearchField(), // TextField
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: _buildCategoryFilter(), // Dropdown
                  ),
                ],
              );
            } else {
              // --- VISTA ANGOSTA: Usa un Column ---
              return Column(
                children: [
                  _buildSearchField(), // TextField
                  SizedBox(height: 16),
                  _buildCategoryFilter(), // Dropdown
                ],
              );
            }
          },
        ),
      ],
    );
  }

  void _onSort (int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      _filterProducts();
    });
  }
  // --- Widgets de ayuda (separados para limpieza) ---

  /// Construye el campo de búsqueda
  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Buscar por Nombre o SKU',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      ),
      onChanged: (value) {
        _searchQuery = value;
        _filterProducts();
      },
    );
  }

  /// Construye el filtro de categoría
  Widget _buildCategoryFilter() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Categoría',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      ),
      initialValue: _selectedCategory,
      items: _categories.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedCategory = newValue!;
        });
        _filterProducts();
      },
    );
  }
  
  // (Debes incluir los métodos _buildSearchField y _buildCategoryFilter 
  // que puse en la Solución 1)

  /// Construye el DataTable principal
  // *** ¡REEMPLAZA TU MÉTODO _buildDataTable CON ESTE! ***

  /// Construye el DataTable principal
  Widget _buildDataTable() {
    return DataTable(
      horizontalMargin: 12.0,
      columnSpacing: 20.0, // <-- Reduje un poco el espacio
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,

      // Definición de las Columnas
      columns: [
        // *** ¡NUEVA COLUMNA DE IMAGEN! (Índice 0) ***
        // Esta columna no tiene 'onSort'
        const DataColumn(
          label: Padding(
            padding: EdgeInsets.only(left: 8.0), // Padding para centrar el 'Img'
            child: Text('Img', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),

        // Columna 1: Producto
        DataColumn(
          label: Text('Producto', style: TextStyle(fontWeight: FontWeight.bold)),
          onSort: _onSort,
        ),
        // Columna 2: SKU
        DataColumn(
          label: Text('SKU', style: TextStyle(fontWeight: FontWeight.bold)),
          onSort: _onSort,
        ),
        // Columna 3: Categoría
        DataColumn(
          label: Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold)),
          onSort: _onSort,
        ),
        // Columna 4: Stock
        DataColumn(
          label: Text('Stock', style: TextStyle(fontWeight: FontWeight.bold)),
          numeric: true,
          onSort: _onSort,
        ),
        // Columna 5: Precio
        DataColumn(
          label: Text('Precio', style: TextStyle(fontWeight: FontWeight.bold)),
          numeric: true,
          onSort: _onSort,
        ),
        // Columna 6: Acciones (SIN onSort)
        DataColumn(
          label: Row(
            children: [
              SizedBox(width: 15.0),
              Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
      
      // Definición de las Filas
      rows: _filteredProducts.map((product) {
        final stockColor = _getStockColor(product.stock);
        return DataRow(
          cells: [
            // *** ¡NUEVA CELDA DE IMAGEN! (Índice 0) ***
            DataCell(
              Padding(
                // Padding vertical para que el CircleAvatar quepa bien
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: CircleAvatar(
                  radius: 20,
                  // Muestra la imagen. Si falla, muestra un ícono.
                  backgroundImage: NetworkImage(product.imageUrl!),
                  onBackgroundImageError: (e, s) {}, // Captura el error
                  child: Builder( // Se usa si la imagen falla
                    builder: (context) {
                       // Si la imagen falla (onBackgroundImageError se dispara)
                       // el backgroundImage es null, y el child se muestra.
                       // Aquí podrías poner un ícono por defecto
                       return const Icon(Icons.image_not_supported, size: 20, color: Colors.grey);
                    }
                  ),
                ),
              ),
            ),
            
            // Celdas existentes (ahora 1-6)
            DataCell(Text(product.name)),
            DataCell(Text(product.sku!)),
            DataCell(Text(product.category.name)),
            DataCell(
              Text(
                product.stock.toString(),
                style: TextStyle(color: stockColor, fontWeight: FontWeight.bold),
              ),
            ),
            DataCell(Text('\$${product.price.toStringAsFixed(2)}')),
            DataCell(
              Row(
                children: [
                  SizedBox(width: 15.0), 
                  IconButton(
                    icon: Icon(Icons.edit, size: 20, color: Colors.blue.shade700),
                    tooltip: 'Editar Producto',
                    onPressed: () => _editProduct(product),
                  ),
                  IconButton(
                    icon: Icon(Icons.inventory_2, size: 20, color: Colors.green.shade700),
                    tooltip: 'Ajustar Stock',
                    onPressed: () => _adjustStock(product),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, size: 20, color: Colors.red.shade700),
                    tooltip: 'Eliminar Producto',
                    onPressed: () => _deleteProduct(product),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  

  /// Helper para determinar el color del indicador de stock
  Color _getStockColor(int stock) {
    if (stock == 0) {
      return Colors.red.shade900;
    } else if (stock <= _stockLowThreshold) {
      return Colors.orange.shade900;
    } else {
      return Colors.green.shade800;
    }
  }

  // --- Lógica de Acciones (Placeholder) ---

  void _addNewProduct() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navegando a la pantalla de "Añadir Producto"...')),
    );
  }

  void _editProduct(Product product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editando ${product.name}...')),
    );
  }

  void _adjustStock(Product product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mostrando diálogo para ajustar stock de ${product.name}...')),
    );
  }

  void _deleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar ${product.name}?'),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
            onPressed: () {
              setState(() {
                _allProducts.remove(product);
                _filterProducts();
              });
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}