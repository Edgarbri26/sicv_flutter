import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sicv_flutter/models/purchase/purchase_summary_model.dart';
import 'package:sicv_flutter/models/sale/sale_summary_model.dart';
import 'package:sicv_flutter/services/report_service.dart';


// SI NO TIENES FilterState DEFINIDO EN OTRO LADO, DESCOMENTA ESTO:
class FilterState {
  final String period; // 'week', 'month', 'year', 'custom', 'all'
  final DateTimeRange? customRange;

  FilterState({this.period = 'month', this.customRange});

  FilterState copyWith({String? period, DateTimeRange? customRange}) {
    return FilterState(
      period: period ?? this.period,
      customRange: customRange ?? this.customRange,
    );
  }
}


// ======================================================
// 1. PROVIDER DEL SERVICIO (SINGLETON)
// ======================================================
final reportServiceProvider = Provider<ReportService>((ref) {
  return ReportService();
});

// ======================================================
// 2. PROVIDER DEL FILTRO (ESTADO DE LA VISTA)
// ======================================================
// Este controla el widget DateFilterSelector
// Inicializamos por defecto en 'month' (Mes actual)
final historyFilterProvider = StateProvider<FilterState>((ref) => FilterState(period: 'month'));

// ======================================================
// 3. LÓGICA DE CÁLCULO DE FECHAS
// ======================================================
// Tu ReportService espera fechas exactas (startDate, endDate).
// Esta función traduce "week", "month" a fechas reales.
({DateTime? start, DateTime? end}) _calculateDates(FilterState filter) {
  final now = DateTime.now();
  DateTime? startDate;
  DateTime? endDate = now;

  // 1. Caso Personalizado
  if (filter.period == 'custom' && filter.customRange != null) {
    return (start: filter.customRange!.start, end: filter.customRange!.end);
  }

  // 2. Casos Predefinidos
  switch (filter.period) {
    case 'week':
      // Últimos 7 días
      startDate = now.subtract(const Duration(days: 7));
      break;
    case 'month':
      // Inicio del mes actual hasta hoy
      startDate = DateTime(now.year, now.month - 1, now.day);
      break;
    case 'year':
      // Último año
      startDate = DateTime(now.year - 1, now.month, now.day);
      break;
    case 'all':
      // Sin filtro de fecha
      startDate = null; 
      endDate = null;
      break;
    default:
      // Por defecto mes actual
       startDate = DateTime(now.year, now.month - 1, now.day);
  }
  return (start: startDate, end: endDate);
}

// ======================================================
// 4. PROVIDERS DE DATOS (CONECTADOS AL REPORTE)
// ======================================================

// A. Historial de Ventas
final salesHistoryProvider = FutureProvider.autoDispose<List<SaleSummaryModel>>((ref) async {
  // 1. Obtenemos el servicio y el filtro actual
  final service = ref.watch(reportServiceProvider);
  final filter = ref.watch(historyFilterProvider);

  // 2. Calculamos las fechas que el backend necesita
  final dates = _calculateDates(filter);

  // 3. Llamamos a tu ReportService existente
  return await service.getSalesByRange(
    filter.period, 
    startDate: dates.start,
    endDate: dates.end,
  );
});

// B. Historial de Compras
final purchasesHistoryProvider = FutureProvider.autoDispose<List<PurchaseSummaryModel>>((ref) async {
  final service = ref.watch(reportServiceProvider);
  final filter = ref.watch(historyFilterProvider);

  final dates = _calculateDates(filter);

  return await service.getPurchasesByRange(
    filter.period,
    startDate: dates.start,
    endDate: dates.end,
  );
});