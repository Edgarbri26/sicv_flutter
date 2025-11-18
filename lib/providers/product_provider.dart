import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sicv_flutter/models/product_model.dart';
import 'package:sicv_flutter/services/product_service.dart';

// 1. Proveedor del Servicio (Para que sea testear y desacoplar)
final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

// 2. El Notifier: Controla la lógica de estado (Cargando, Error, Datos)
class ProductsNotifier extends StateNotifier<AsyncValue<List<ProductModel>>> {
  final ProductService _service;

  ProductsNotifier(this._service) : super(const AsyncValue.loading()) {
    loadProducts();
  }

  // Cargar productos
  Future<void> loadProducts() async {
    try {
      state = const AsyncValue.loading();
      final products = await _service.getAll();
      state = AsyncValue.data(products);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Refrescar sin mostrar pantalla de carga completa (útil tras añadir un producto)
  Future<void> refresh() async {
    try {
      final products = await _service.getAll();
      state = AsyncValue.data(products);
    } catch (e) {
      // Si falla el refresh silencioso, no cambiamos el estado actual
      print("Error refrescando productos: $e");
    }
  }

  // Crear producto
  Future<void> createProduct({
    required String name,
    required String sku,
    required String description,
    required int categoryId,
    required double price,
    required Uint8List? imageUrl,
    required int minStock,
    required bool isPerishable,
  }) async {
    // Llamamos al servicio
    await _service.createProduct(
      name: name,
      sku: sku,
      description: description,
      categoryId: categoryId,
      price: price,
      imageUrl: imageUrl,
      minStock: minStock,
      isPerishable: isPerishable,
    );
    // Si tiene éxito, recargamos la lista
    await refresh();
  }

  // Eliminar producto (Optimistic Update: borra visualmente primero)
  Future<void> deleteProduct(ProductModel product) async {
    final previousState = state;
    
    // 1. Actualización Optimista: Quitamos el item de la lista inmediatamente
    if (state.hasValue) {
      state = AsyncValue.data(
        state.value!.where((p) => p.id != product.id).toList(),
      );
    }

    try {
      // 2. Llamada a la API
      await _service.deactivateProduct(product.id);
    } catch (e) {
      // 3. Si falla, revertimos los cambios (Rollback)
      state = previousState;
      throw e; 
    }
  }
}


// 3. El Proveedor Global que usará tu pantalla
final productsProvider = StateNotifierProvider<ProductsNotifier, AsyncValue<List<ProductModel>>>((ref) {
  final service = ref.watch(productServiceProvider);
  return ProductsNotifier(service);
});