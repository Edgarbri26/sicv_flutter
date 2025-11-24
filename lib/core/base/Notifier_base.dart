import 'package:flutter_riverpod/legacy.dart';
import 'package:sicv_flutter/core/base/services_base.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// <T> será el Modelo (ProviderModel)
// <S> será el Servicio que implementa CrudInterface
abstract class BaseCrudNotifier<T> extends StateNotifier<AsyncValue<List<T>>> {
  final ServicesInterface<T> _service;

  BaseCrudNotifier(this._service) : super(const AsyncValue.loading()) {
    loadItems();
  }

  // Lógica estándar para cargar datos
  Future<void> loadItems() async {
    try {
      state = const AsyncValue.loading();
      final items = await _service.getAll();
      state = AsyncValue.data(items);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Lógica estándar para refrescar (sin poner el estado en loading visualmente si no quieres)
  Future<void> refresh() async {
    try {
      final items = await _service.getAll();
      state = AsyncValue.data(items);
    } catch (e) {
      print("Error refrescando: $e");
    }
  }

  // Método auxiliar para manejar operaciones (Create, Update, Delete)
  // Ejecuta la acción y luego recarga la lista automáticamente
  Future<void> performAction(Future<void> Function() action) async {
    try {
      await action();
      await refresh(); // Recargamos la lista para ver los cambios
    } catch (e, stack) {
      // Opcional: Manejar error global o mostrar snackbar aquí
      state = AsyncValue.error(e, stack); 
    }
  }
}