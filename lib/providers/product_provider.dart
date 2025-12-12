import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sicv_flutter/models/product/product_model.dart';
import 'package:sicv_flutter/models/product/stock_option_model.dart';
import 'package:sicv_flutter/services/product_service.dart';

// 1. Proveedor del Servicio
final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

// --- CORRECCIÓN: EL PROVIDER VA AQUÍ, AFUERA DE LA CLASE ---
final productStockDetailProvider = 
    FutureProvider.family<List<StockOptionModel>, int>((ref, productId) async {
  
  // Usamos 'watch' para obtener el servicio
  final service = ref.watch(productServiceProvider);
  
  // Llama al método del servicio
  return await service.getStockDetails(productId);
});

// 2. El Notifier
class ProductsNotifier extends StateNotifier<AsyncValue<List<ProductModel>>> {
  final ProductService _service;

  ProductsNotifier(this._service) : super(const AsyncValue.loading()) {
    loadProducts();
  }

  // (YA NO PONGAS EL PROVIDER AQUÍ ADENTRO)

  // Cargar productos
  Future<void> loadProducts() async {
    try {
      state = const AsyncValue.loading();
      final products = await _service.getAll();
      if (mounted) state = AsyncValue.data(products);
    } catch (e, stack) {
      if (mounted) state = AsyncValue.error(e, stack);
    }
  }

  // Refrescar silencioso
  Future<void> refresh() async {
    try {
      final products = await _service.getAll();
      if (mounted) state = AsyncValue.data(products);
    } catch (e) {
      debugPrint("Error refrescando productos: $e");
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
    await refresh();
  }

  // Actualizar producto
  Future<void> updateProduct({
    required int id,
    required String name,
    required String sku,
    required int categoryId,
    required String description,
    required int minStock,
    required double price,
    Uint8List? imageUrl,
  }) async {
    try {
      await _service.update(
        id: id,
        name: name,
        sku: sku,
        categoryId: categoryId,
        description: description,
        price: price,
        minStock: minStock,
        imageUrl: imageUrl,
      );
      await refresh();
    } catch (e) {
      rethrow;
    }
  }

  // Eliminar producto
  Future<void> deleteProduct(ProductModel product) async {
    final previousState = state;

    if (state.hasValue) {
      state = AsyncValue.data(
        state.value!.where((p) => p.id != product.id).toList(),
      );
    }

    try {
      await _service.deactivateProduct(product.id);
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }
}

// 3. El Proveedor Global
final productsProvider =
    StateNotifierProvider<ProductsNotifier, AsyncValue<List<ProductModel>>>((
      ref,
    ) {
      final service = ref.watch(productServiceProvider);
      return ProductsNotifier(service);
    });