import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sicv_flutter/models/movement_model.dart';
import 'package:sicv_flutter/models/movement_type.dart';
import 'package:sicv_flutter/services/movement_service.dart';

// 1. Estado de los filtros
class MovementFilterState {
  final String searchQuery;
  final MovementType? movementType;
  final String dateRange;
  final String? user;
  final int? sortColumnIndex;
  final bool sortAscending;

  MovementFilterState({
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
      movementType: movementType, // Permite nulos explícitos
      dateRange: dateRange ?? this.dateRange,
      user: user, // Permite nulos explícitos
      sortColumnIndex: sortColumnIndex ?? this.sortColumnIndex,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

final movementFilterProvider = StateProvider<MovementFilterState>((ref) {
  return MovementFilterState();
});

// 2. Carga de datos crudos (Async)
final movementsRawProvider = FutureProvider<List<MovementModel>>((ref) async {
  return await MovementService().getAll();
});

// 3. Lógica de filtrado y ordenamiento (Computed)
final filteredMovementsProvider = Provider<AsyncValue<List<MovementModel>>>((ref) {
  final movementsAsync = ref.watch(movementsRawProvider);
  final filters = ref.watch(movementFilterProvider);

  return movementsAsync.whenData((movements) {
    var results = List<MovementModel>.from(movements);
    final now = DateTime.now();
    DateTime startDate;

    // 1. Filtro Fecha
    switch (filters.dateRange) {
      case 'Hoy':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Ayer':
        final yesterday = now.subtract(const Duration(days: 1));
        startDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
        // Caso especial Ayer (rango estricto)
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

    // 2. Tipo y Usuario
    if (filters.movementType != null) {
      results = results.where((m) => m.type == filters.movementType).toList();
    }
    if (filters.user != null) {
      results = results.where((m) => m.user?.name == filters.user).toList();
    }

    // 3. Búsqueda
    if (filters.searchQuery.isNotEmpty) {
      final query = filters.searchQuery.toLowerCase();
      results = results.where((m) =>
          (m.product?.name.toLowerCase().contains(query) ?? false) ||
          (m.product?.sku?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    // 4. Ordenamiento
    if (filters.sortColumnIndex != null) {
      results.sort((a, b) {
        dynamic aValue, bValue;
        switch (filters.sortColumnIndex) {
          case 0: // Fecha
            aValue = a.movedAt; bValue = b.movedAt; break;
          case 1: // Producto
            aValue = a.product?.name ?? ''; bValue = b.product?.name ?? ''; break;
          case 2: // Tipo
            aValue = a.type.toString(); bValue = b.type.toString(); break;
          case 3: // Cantidad
            aValue = a.amount; bValue = b.amount; break;
          case 6: // Usuario
            aValue = a.user?.name ?? ''; bValue = b.user?.name ?? ''; break;
          default: return 0;
        }
        final cmp = aValue.compareTo(bValue);
        return filters.sortAscending ? cmp : -cmp;
      });
    } else {
      // Orden por defecto: fecha descendente
      results.sort((a, b) => b.movedAt.compareTo(a.movedAt));
    }

    return results;
  });
});