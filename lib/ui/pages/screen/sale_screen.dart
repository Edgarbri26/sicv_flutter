// lib/ui/pages/sale_screen.dart

import 'package:flutter/material.dart';
import 'package:sicv_flutter/models/product.dart'; // <-- Usa tu modelo Product
import 'package:sicv_flutter/services/product_api_service.dart';
import 'package:sicv_flutter/ui/widgets/App_search_bar.dart';
import 'package:sicv_flutter/ui/widgets/product_card.dart';

class SaleScreen extends StatefulWidget {
  // Ahora esta lista debe ser de tipo Product
  final List<Product> saleItemsSelled; 
  const SaleScreen({super.key, required this.saleItemsSelled});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  final ProductApiService _apiService = ProductApiService();
  TextEditingController searchController = TextEditingController();

  // Variables de estado
  bool _isLoading = true;
  String? _errorMessage;
  List<Product> _availableProducts = [];
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    searchController.addListener(_filterItems);
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await _apiService.getProducts();
      setState(() {
        _availableProducts = products;
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
      _filteredProducts = _availableProducts.where((product) {
        return product.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  // Método adaptado para añadir un objeto Product a la lista de venta
  void _addNewItemToSale(Product newProduct) {
    setState(() {
      // Aquí puedes añadir lógica para evitar duplicados si lo necesitas
      widget.saleItemsSelled.add(newProduct);
    });
    
    // Muestra una notificación de que el producto fue añadido
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${newProduct.name} añadido a la venta.'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppSearchBar(
          searchController: searchController,
          hintText: 'Buscar producto para vender...',
        ),
        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchProducts,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    
    if (_filteredProducts.isEmpty) {
        return const Center(child: Text('No se encontraron productos.'));
    }

    return ListView.builder(
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return ProductCard(
          product: product,
          onTap: () => _addNewItemToSale(product), // Un tap simple también puede añadir
          onDelete: () {}, // La eliminación no aplica aquí
          /*trailing: IconButton(
            onPressed: () => _addNewItemToSale(product),
            icon: const Icon(Icons.add_shopping_cart_outlined),
          ),*/
        );
      },
    );
  }
}