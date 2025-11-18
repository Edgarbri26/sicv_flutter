import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sicv_flutter/models/category_model.dart';
import 'package:sicv_flutter/services/category_service.dart';

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService();
});

// 2. El Notifier: Controla la lógica de estado (Cargando, Error, Datos)
class CategoriesNotifier
    extends StateNotifier<AsyncValue<List<CategoryModel>>> {
  final CategoryService _service;

  CategoriesNotifier(this._service) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  // Cargar categorías
  Future<void> loadCategories() async {
    try {
      state = const AsyncValue.loading();
      final categories = await _service.getAll();
      state = AsyncValue.data(categories);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Refrescar sin mostrar pantalla de carga completa (útil tras añadir una categoría)
  Future<void> refresh() async {
    try {
      final categories = await _service.getAll();
      state = AsyncValue.data(categories);
    } catch (e) {
      // Si falla el refresh silencioso, no cambiamos el estado actual
      print("Error refrescando categorías: $e");
    }
  }

  // Crear categoría
  Future<void> createCategory({
    required String name,
    required String description,
  }) async {
    // Llamamos al servicio
    await _service.create(name, description);
    // Si tiene éxito, recargamos la lista
    await refresh();
  }

  Future<void> updateCategory({
    required int id,
    required String name,
    required String description,
    required bool status,
  }) async {
    // Llamamos al servicio
    await _service.update(id, name, description, status);
    // Si tiene éxito, recargamos la lista
    await refresh();
  }

  Future<void> activateCategory(int id) async {
    // Llamamos al servicio
    await _service.activate(id);
    // Si tiene éxito, recargamos la lista
    await refresh();
  }

  Future<void> deactivateCategory(int id) async {
    // Llamamos al servicio
    await _service.deactivate(id);
    // Si tiene éxito, recargamos la lista
    await refresh();
  }
}

final categoryProvider =
    StateNotifierProvider<CategoriesNotifier, AsyncValue<List<CategoryModel>>>((
      ref,
    ) {
      final service = ref.watch(categoryServiceProvider);
      return CategoriesNotifier(service);
    });
