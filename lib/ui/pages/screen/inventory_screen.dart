// lib/ui/pages/inventory_screen.dart

import 'package:flutter/material.dart';
import 'package:sicv_flutter/models/product.dart'; // <-- Usa tu nuevo modelo Product
import 'package:sicv_flutter/services/product_api_service.dart'; // <-- Importa el servicio
import '../../widgets/product_card.dart'; // Tu widget para mostrar cada producto
// ...otras importaciones

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final ProductApiService _apiService = ProductApiService();
  TextEditingController searchController = TextEditingController();

  // Variables para manejar el estado de la carga de datos
  bool _isLoading = true;
  String? _errorMessage;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts(); // Llama al método para cargar datos desde la API
    searchController.addListener(_filterItems);
  }

  // Método para obtener los productos desde la API
  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await _apiService.getProducts();
      setState(() {
        _products = products;
        _filteredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterItems() {
    final query = searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _products.where((product) {
        return product.name.toLowerCase().contains(query) ||
               product.description.toLowerCase().contains(query);
      }).toList();
    });
  }
  
  // ... (tus métodos _editItem y _deleteItem necesitarán ser adaptados para usar el servicio de API también)

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tu barra de búsqueda
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Buscar en inventario...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        // Contenido principal que cambia según el estado
        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildContent() {
    // 1. Si está cargando, muestra un indicador de progreso
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Si hay un error, muestra un mensaje y un botón para reintentar
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_errorMessage', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchProducts,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    
    // 3. Si no hay productos, muestra un mensaje
    if (_filteredProducts.isEmpty) {
        return const Center(child: Text('No se encontraron productos.'));
    }

    // 4. Si todo está bien, muestra la lista de productos
    return ListView.builder(
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        // Aquí debes usar un widget 'ProductCard' adaptado para recibir un objeto 'Product'
        return ProductCard(
          product: product, // Pasa el objeto Product
          onTap: () { /* Lógica para editar */ },
          onDelete: () { /* Lógica para eliminar */ },
          
        );
      },
    );
  }
}