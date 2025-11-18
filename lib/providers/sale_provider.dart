import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sicv_flutter/models/product_model.dart';
import 'package:sicv_flutter/providers/product_provider.dart';// Asegúrate de que este sea el path correcto

// 1. Proveedor del Estado de Búsqueda
// Almacena el texto que el usuario escribe en el TextField (después del debounce).
final saleSearchTermProvider = StateProvider<String>((ref) => '');

// 2. Proveedor del Estado de Categoría Seleccionada
// Almacena el ID de la categoría seleccionada (0 significa "Todos").
final saleSelectedCategoryIdProvider = StateProvider<int>((ref) => 0); 

// 3. Proveedor Derivado: La lista de productos filtrados (CRÍTICO)
// Observa la lista maestra de productos (productsProvider) y los filtros.
final filteredProductsProvider = Provider<List<ProductModel>>((ref) {
  // Observa la lista maestra de productos (AsyncValue<List<ProductModel>>)
  final AsyncValue<List<ProductModel>> productsAsync = ref.watch(productsProvider);

  // Obtiene la lista real. Si está en loading o error, retorna una lista vacía para evitar fallos.
  final List<ProductModel> allProducts = productsAsync.value ?? [];

  // Observa los parámetros de filtrado.
  final searchTerm = ref.watch(saleSearchTermProvider).toLowerCase();
  final categoryId = ref.watch(saleSelectedCategoryIdProvider);

  List<ProductModel> results = allProducts;

  // --- FILTRO 1: Por Categoría ---
  if (categoryId != 0) {
    results = results
        .where((product) => product.category.id == categoryId)
        .toList();
  }

  // --- FILTRO 2: Por Término de Búsqueda (Nombre o SKU) ---
  if (searchTerm.isNotEmpty) {
    results = results
        .where(
          (product) =>
              // Filtra por nombre (en minúsculas)
              product.name.toLowerCase().contains(searchTerm) ||
              // Filtra por SKU (maneja el caso de que SKU sea nulo)
              (product.sku ?? '').toLowerCase().contains(searchTerm),
        )
        .toList();
  }

  return results; // Devuelve la lista que ya pasó por ambos filtros.
});