// inventory_report_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:sicv_flutter/models/report/inventory_efficiency.dart';
import 'package:sicv_flutter/services/report_service.dart';

// --- CLASES DE DATOS ---
// (Mantenemos tus clases AppPieChartData, ProductMetric, StockAlert, InventoryState iguales)
// ... (Copia tus clases aquí tal cual las tenías en tu mensaje anterior) ...

class AppPieChartData {
  final String name;
  final double value;
  final Color color;
  AppPieChartData(this.name, this.value, this.color);
}

class ProductMetric {
  final String name;
  final int soldCount;
  final double percentage;
  ProductMetric(this.name, this.soldCount, this.percentage);
}

class StockAlert {
  final String name;
  final int quantity;
  final String level;
  StockAlert(this.name, this.quantity, this.level);
}

class InventoryState {
  final List<InventoryEfficiencyPoint> efficiencyData;
  final String totalInventoryValue;
  final int totalItems;
  final List<AppPieChartData> categoryDistribution;
  final List<ProductMetric> topProducts;
  final int lowStockAlerts;
  final String monthlyTurnover;
  final List<StockAlert> lowStockItems;
  
  // Añadimos isLoading para manejar la carga visualmente si quieres
  final bool isLoading;

  InventoryState({
    this.efficiencyData = const [],
    this.totalInventoryValue = "0.00",
    this.totalItems = 0,
    this.categoryDistribution = const [],
    this.topProducts = const [],
    this.lowStockAlerts = 0,
    this.monthlyTurnover = "-",
    this.lowStockItems = const [],
    this.isLoading = true,
  });
  
  // Método copyWith para actualizar estado fácil
  InventoryState copyWith({
    List<InventoryEfficiencyPoint>? efficiencyData,
    String? totalInventoryValue,
    int? totalItems,
    List<AppPieChartData>? categoryDistribution,
    List<ProductMetric>? topProducts,
    bool? isLoading,
  }) {
    return InventoryState(
      efficiencyData: efficiencyData ?? this.efficiencyData,
      totalInventoryValue: totalInventoryValue ?? this.totalInventoryValue,
      totalItems: totalItems ?? this.totalItems,
      categoryDistribution: categoryDistribution ?? this.categoryDistribution,
      topProducts: topProducts ?? this.topProducts,
      isLoading: isLoading ?? this.isLoading,
      // Mocks se mantienen
      lowStockAlerts: this.lowStockAlerts,
      monthlyTurnover: this.monthlyTurnover,
      lowStockItems: this.lowStockItems,
    );
  }
}

// --- CONTROLLER / NOTIFIER ---

class InventoryReportNotifier extends StateNotifier<InventoryState> {
  final ReportService _service = ReportService();
  
  // Estado del Filtro Interno
  String _currentFilter = 'month';
  DateTimeRange? _currentDateRange;

  // Getters para que la UI sepa qué mostrar en el DateFilterSelector
  String get currentFilter => _currentFilter;
  DateTimeRange? get currentDateRange => _currentDateRange;

  InventoryReportNotifier() : super(InventoryState()) {
    loadData(); // Cargar al inicio
  }

  // 1. Cambiar Filtro Rápido (Hoy, Semana...)
  void setFilter(String filter) {
    _currentFilter = filter;
    _currentDateRange = null; // Limpiar rango custom
    loadData();
  }

  // 2. Cambiar Rango Personalizado
  void setDateRange(DateTimeRange range) {
    _currentFilter = 'custom';
    _currentDateRange = range;
    loadData();
  }

  Future<void> loadData() async {
    // 1. Marcamos cargando
    state = state.copyWith(isLoading: true);

    try {
      // 2. Ejecutamos peticiones en paralelo pasando las fechas
      final results = await Future.wait([
        _service.getInventoryEfficiency(_currentFilter, start: _currentDateRange?.start, end: _currentDateRange?.end),
        _service.getInventoryValue(), // Asumo snapshot global
        _service.getTotalItems(),     // Asumo snapshot global
        _service.getInventoryByCategory(), // Asumo snapshot global
        _service.getTopSellingProducts(_currentFilter, start: _currentDateRange?.start, end: _currentDateRange?.end),
      ]);

      // 3. Procesamos resultados
      final efficiencyData = results[0] as List<InventoryEfficiencyPoint>;
      final inventoryValue = results[1] as double;
      final totalItems = results[2] as int;
      final categoryRawData = results[3] as List<Map<String, dynamic>>;
      final topProductsRawData = results[4] as List<Map<String, dynamic>>;

      // 4. Mapeo de Categorías
      Color parseColor(String hexString) {
        final buffer = StringBuffer();
        if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
        buffer.write(hexString.replaceFirst('#', ''));
        return Color(int.parse(buffer.toString(), radix: 16));
      }

      final categoryDistribution = categoryRawData.map((item) {
        return AppPieChartData(
          item['name'] as String,
          (item['percentage'] as num).toDouble(),
          parseColor(item['color'] as String),
        );
      }).toList();

      // 5. Mapeo de Top Productos
      final topProducts = topProductsRawData.map((item) {
        return ProductMetric(
          item['name'] as String,
          item['soldCount'] as int,
          (item['percentage'] as num).toDouble(),
        );
      }).toList();

      final currencyFormat = NumberFormat("#,##0.00", "en_US");

      // 6. Actualizamos el estado
      state = InventoryState(
        isLoading: false,
        efficiencyData: efficiencyData,
        totalInventoryValue: currencyFormat.format(inventoryValue),
        totalItems: totalItems,
        categoryDistribution: categoryDistribution,
        topProducts: topProducts,
        // Mocks
        lowStockAlerts: 5,
        monthlyTurnover: "18%",
        lowStockItems: [
          StockAlert("Adaptador HDMI", 2, "Crítico"),
          StockAlert("Funda iPhone 13", 4, "Bajo"),
        ],
      );

    } catch (e) {
      debugPrint("Error loading inventory report: $e");
      // Podrías manejar un estado de error aquí
      state = state.copyWith(isLoading: false);
    }
  }
}

// --- PROVIDER FINAL ---

final inventoryReportProvider = StateNotifierProvider<InventoryReportNotifier, InventoryState>((ref) {
  return InventoryReportNotifier();
});