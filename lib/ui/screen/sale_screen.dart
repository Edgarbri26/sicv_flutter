// lib/ui/pages/screen/sale_screen.dart

import 'package:flutter/material.dart';
import 'package:sicv_flutter/models/category.dart';
import 'package:sicv_flutter/models/product.dart';

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
  late List<Category> _categories;
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
      Product(id: 1, name: 'Harina PAN', description: '...', price: 1.40, stock: 50, category: Category(id: 1, name: 'Alimentos'), sku: 'ALI-001'),
      Product(id: 2, name: 'Cigarros Marlboro', description: '...', price: 5.99, stock: 5, category: Category(id: 2, name: 'Tabaco'), sku: 'TAB-001'),
      Product(id: 3, name: 'Café', description: '...', price: 10.99, stock: 0, category: Category(id: 3, name: 'Bebidas'), sku: 'BEB-001'),
      Product(id: 4, name: 'Gaseosa 2L', description: '...', price: 2.5, stock: 50, category: Category(id: 3, name: 'Bebidas'), sku: 'BEB-002'),
      Product(id: 5, name: 'Pan Campesino', description: '...', price: 2.0, stock: 15, category: Category(id: 1, name: 'Alimentos'), sku: 'ALI-002'),
      Product(id: 6, name: 'Agua Minalba 1L', description: '...', price: 1.0, stock: 30, category: Category(id: 3, name: 'Bebidas'), sku: 'BEB-003'),
    ];

    // Simula la carga de categorías (DEBERÍAS TRAERLAS DE TU API/BD)
    _categories = [
      Category(id: 0, name: 'Todos'), // Categoría especial
      Category(id: 1, name: 'Alimentos'),
      Category(id: 2, name: 'Tabaco'),
      Category(id: 3, name: 'Bebidas'),
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
          .where((product) =>
              product.name.toLowerCase().contains(searchText) ||
              (product.sku ?? '').toLowerCase().contains(searchText)) // Busca por nombre o SKU
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
        // --- 1. WIDGET DE BÚSQUEDA ---
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Buscar producto por nombre o SKU',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              // Añade un botón para limpiar el texto
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
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
                  itemCount: _productosFiltrados.length, // Usa la lista filtrada
                  itemBuilder: (context, index) {
                    final product = _productosFiltrados[index]; // Usa la lista filtrada
                    bool isOutOfStock = product.stock == 0;

                    return Card(
                      clipBehavior: Clip.antiAlias,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
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
                                child: Container(
                                  color: Colors.grey.shade200,
                                  child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                                      ? Image.network(product.imageUrl!, fit: BoxFit.cover)
                                      : Icon(Icons.inventory_2, size: 40, color: Colors.grey.shade400),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Spacer(),
                                      Text(
                                        '\$${product.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 15,
                                        ),
                                      ),
                                      // --- MEJORA DE UI (STOCK) ---
                                      if (isOutOfStock)
                                        Text(
                                          'Agotado',
                                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 10),
                                        )
                                      else if (product.stock <= 10) // Muestra si queda poco stock
                                        Text(
                                          'Quedan: ${product.stock}',
                                          style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold, fontSize: 10),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
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
              backgroundColor: Colors.grey.shade200,
              shape: StadiumBorder(
                side: BorderSide(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}