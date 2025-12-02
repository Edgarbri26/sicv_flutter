import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sicv_flutter/models/movement/movement_model.dart';
import 'package:sicv_flutter/models/movement/movement_summary_model.dart';
import 'package:sicv_flutter/models/movement/movement_type.dart';
import 'package:sicv_flutter/services/movement_service.dart';

// 1. Servicio
final movementServiceProvider = Provider<MovementService>((ref) => MovementService());

// 2. Estado de los Filtros (Variables reactivas)
final movementSearchProvider = StateProvider<String>((ref) => '');
final movementTypeFilterProvider = StateProvider<MovementType?>((ref) => null);
final movementDateRangeProvider = StateProvider<String>((ref) => 'Últimos 7 días');
final movementUserFilterProvider = StateProvider<String?>((ref) => null);

// 3. Provider que carga los movimientos crudos del API (Notifier para poder recargar)
class MovementsNotifier extends StateNotifier<AsyncValue<List<MovementSummaryModel>>> {
  final MovementService _service;
  
  MovementsNotifier(this._service) : super(const AsyncValue.loading()) {
    loadMovements();
  }

  Future<void> loadMovements() async {
    try {
      state = const AsyncValue.loading();
      final movements = await _service.getAll();
      // Ordenamos por defecto por fecha descendente
      movements.sort((a, b) => b.movedAt.compareTo(a.movedAt));
      state = AsyncValue.data(movements);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Método para crear y recargar
  Future<void> createMovement(MovementModel movement, {Map<String, dynamic>? extraData}) async {
    // Aquí tu lógica de llamada al servicio de crear...
    // Asumimos que tienes un método create en el servicio adaptado
    // await _service.create(movement, extraData: extraData); 
    // Por ahora simulamos la recarga:
    await loadMovements(); 
  }
}

final movementsProvider = StateNotifierProvider<MovementsNotifier, AsyncValue<List<MovementSummaryModel>>>((ref) {
  final service = ref.watch(movementServiceProvider);
  return MovementsNotifier(service);
});

// 4. Provider "Inteligente": Devuelve la lista YA FILTRADA
final filteredMovementsProvider = Provider<List<MovementSummaryModel>>((ref) {
  final movementsAsync = ref.watch(movementsProvider);
  final searchQuery = ref.watch(movementSearchProvider).toLowerCase();
  final typeFilter = ref.watch(movementTypeFilterProvider);
  final dateFilter = ref.watch(movementDateRangeProvider);
  final userFilter = ref.watch(movementUserFilterProvider);

  return movementsAsync.when(
    loading: () => [],
    error: (_, __) => [],
    data: (movements) {
      return movements.where((m) {
        // 1. Filtro de Texto
        final matchesSearch = m.productName.toLowerCase().contains(searchQuery) || 
                              m.observation.toLowerCase().contains(searchQuery);
        if (!matchesSearch) return false;

        // 2. Filtro de Tipo
        if (typeFilter != null && m.type != typeFilter.displayName) return false;

        // 3. Filtro de Usuario
        if (userFilter != null && m.userName != userFilter) return false;

        // 4. Filtro de Fecha
        final now = DateTime.now();
        final date = m.movedAt;
        switch (dateFilter) {
          case 'Hoy':
            return date.year == now.year && date.month == now.month && date.day == now.day;
          case 'Ayer':
            final yesterday = now.subtract(const Duration(days: 1));
            return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
          case 'Últimos 7 días':
            return date.isAfter(now.subtract(const Duration(days: 7)));
          case 'Este mes':
            return date.year == now.year && date.month == now.month;
          case 'Todos':
          default:
            return true;
        }
      }).toList();
    },
  );
});