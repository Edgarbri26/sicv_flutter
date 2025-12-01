import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sicv_flutter/models/movement/movement_model.dart';
import 'package:sicv_flutter/models/movement/movement_summary_model.dart';
import 'package:sicv_flutter/models/movement/movement_type.dart';
import 'package:sicv_flutter/services/movement_service.dart';

// =============================================================================
// 1. ESTADO DE LOS FILTROS (Igual que antes, funciona bien)
// =============================================================================
class MovementFilterState {
  final String searchQuery;
  final MovementType? movementType;
  final String dateRange;
  final String? user;
  final int? sortColumnIndex;
  final bool sortAscending;

  const MovementFilterState({
    this.searchQuery = '',
    this.movementType,
    this.dateRange = 'Últimos 7 días',
    this.user,
    this.sortColumnIndex,
    this.sortAscending = true,
  });

  MovementFilterState copyWith({
    String? searchQuery,
    MovementType? movementType,
    String? dateRange,
    String? user,
    int? sortColumnIndex,
    bool? sortAscending,
  }) {
    return MovementFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      movementType: movementType ?? this.movementType,
      dateRange: dateRange ?? this.dateRange,
      user: user ?? this.user,
      sortColumnIndex: sortColumnIndex ?? this.sortColumnIndex,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

class MovementFilterNotifier extends StateNotifier<MovementFilterState> {
  MovementFilterNotifier() : super(const MovementFilterState());

  void setSearchQuery(String query) => state = state.copyWith(searchQuery: query);
  void setDateRange(String range) => state = state.copyWith(dateRange: range);
  
  void setMovementType(MovementType? type) {
    // Reconstruimos para permitir nulos
    state = MovementFilterState(
      searchQuery: state.searchQuery,
      dateRange: state.dateRange,
      user: state.user,
      sortColumnIndex: state.sortColumnIndex,
      sortAscending: state.sortAscending,
      movementType: type,
    );
  }

  void setUser(String? user) {
    state = MovementFilterState(
      searchQuery: state.searchQuery,
      dateRange: state.dateRange,
      movementType: state.movementType,
      sortColumnIndex: state.sortColumnIndex,
      sortAscending: state.sortAscending,
      user: user,
    );
  }

  void setSort(int columnIndex, bool ascending) {
    state = state.copyWith(sortColumnIndex: columnIndex, sortAscending: ascending);
  }
  
  void reset() => state = const MovementFilterState();
}

final movementFilterProvider = StateNotifierProvider<MovementFilterNotifier, MovementFilterState>((ref) {
  return MovementFilterNotifier();
});


// =============================================================================
// 2. NOTIFIER DE DATOS (CRUD) - AQUÍ ESTÁ LA MEJORA PRINCIPAL
// =============================================================================

// Servicio Provider (para inyección de dependencias)
final movementServiceProvider = Provider<MovementService>((ref) => MovementService());

class MovementsNotifier extends StateNotifier<AsyncValue<List<MovementSummaryModel>>> {
  final MovementService _service;

  MovementsNotifier(this._service) : super(const AsyncValue.loading()) {
    loadMovements();
  }

  // A. Cargar lista inicial
  Future<void> loadMovements() async {
    try {
      state = const AsyncValue.loading();
      final movements = await _service.getAll();
      state = AsyncValue.data(movements);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // B. Refrescar sin poner estado en loading (silencioso)
  Future<void> refresh() async {
    try {
      final movements = await _service.getAll();
      state = AsyncValue.data(movements);
    } catch (e) {
      print("Error refrescando movimientos: $e");
    }
  }

  // C. CREAR MOVIMIENTO (Lo que pediste)
  Future<void> createMovement(MovementModel newMovement) async {
    try {
      // 1. Enviamos al backend
      // Asumimos que tu service tiene un método create(MovementModel m)
      await _service.create(newMovement); 
      
      // 2. Opción A: Refrescar todo (Más seguro, trae ID real y fecha del server)
      await refresh();

      // 2. Opción B: Optimista (Más rápido, inserta localmente)
      // Si usas esto, recuerda que el ID será null hasta que refresques
      /*
      state.whenData((currentList) {
        state = AsyncValue.data([newMovement, ...currentList]);
      });
      */
    } catch (e) {
      throw e; // Re-lanzamos para que la UI muestre el SnackBar de error
    }
  }
}

// El Provider Global de Datos
final movementsProvider = StateNotifierProvider<MovementsNotifier, AsyncValue<List<MovementSummaryModel>>>((ref) {
  final service = ref.watch(movementServiceProvider);
  return MovementsNotifier(service);
});


// =============================================================================
// 3. PROVIDER DE RESULTADOS FILTRADOS (COMPUTED)
// =============================================================================
final filteredMovementsProvider = Provider<AsyncValue<List<MovementSummaryModel>>>((ref) {
  // Escuchamos los DATOS crudos (del Notifier nuevo)
  final movementsAsync = ref.watch(movementsProvider);
  // Escuchamos los FILTROS
  final filters = ref.watch(movementFilterProvider);

  return movementsAsync.whenData((movements) {
    // Usamos 'List.of' para asegurar que sea modificable
    var results = List<MovementSummaryModel>.of(movements);
    final now = DateTime.now();
    DateTime startDate;

    // --- LÓGICA DE FILTRADO (Idéntica a la anterior) ---
    switch (filters.dateRange) {
      case 'Hoy':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Ayer':
        final yesterday = now.subtract(const Duration(days: 1));
        startDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
        results = results.where((m) =>
            m.movedAt.isAfter(startDate) &&
            m.movedAt.isBefore(DateTime(now.year, now.month, now.day))).toList();
        break;
      case 'Últimos 7 días':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'Este mes':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Todos':
      default:
        startDate = DateTime(2000);
    }

    if (filters.dateRange != 'Ayer') {
      results = results.where((m) => m.movedAt.isAfter(startDate)).toList();
    }

    if (filters.movementType != null) {
      results = results.where((m) => m.type == filters.movementType!.displayName).toList();
    }

    if (filters.user != null && filters.user!.isNotEmpty) {
      results = results.where((m) => m.userName == filters.user).toList();
    }

    if (filters.searchQuery.isNotEmpty) {
      final query = filters.searchQuery.toLowerCase();
      results = results.where((m) {
        final prod = m.productName.toLowerCase();
        final obs = m.observation.toLowerCase();
        return prod.contains(query) || obs.contains(query);
      }).toList();
    }

    // --- LÓGICA DE ORDENAMIENTO ---
    if (filters.sortColumnIndex != null) {
      results.sort((a, b) {
        dynamic aValue, bValue;
        switch (filters.sortColumnIndex) {
          case 0: aValue = a.movedAt; bValue = b.movedAt; break;
          case 1: aValue = a.productName; bValue = b.productName; break;
          case 2: aValue = a.type; bValue = b.type; break;
          case 3: aValue = a.amount; bValue = b.amount; break;
          case 4: aValue = a.userName; bValue = b.userName; break;
          default: return 0;
        }
        final cmp = aValue.compareTo(bValue);
        return filters.sortAscending ? cmp : -cmp;
      });
    } else {
      results.sort((a, b) => b.movedAt.compareTo(a.movedAt));
    }

    return results;
  });
});