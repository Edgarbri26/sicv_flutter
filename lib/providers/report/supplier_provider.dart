import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:sicv_flutter/providers/report/inventory_provider.dart' show AppPieChartData;
import 'package:sicv_flutter/services/report_service.dart';

// Importa tu FilterState común (o defínelo aquí si no tienes uno global)
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
// ==========================================
// 1. MODELOS DE ESTADO (UI)
// ==========================================

class SupplierPerformanceRow {
  final String name;
  final double totalSpent;
  final int purchaseCount;
  final double percentage;
  
  SupplierPerformanceRow({
    required this.name,
    required this.totalSpent,
    required this.purchaseCount,
    required this.percentage,
  });
}

class SupplierReportState {
  final String totalSpentGlobal;
  final int totalTransactions;
  final int totalSuppliers;
  final String topSupplierName;
  final List<AppPieChartData> spendingDistribution;
  final List<SupplierPerformanceRow> suppliersList;

  SupplierReportState({
    required this.totalSpentGlobal,
    required this.totalTransactions,
    required this.totalSuppliers,
    required this.topSupplierName,
    required this.spendingDistribution,
    required this.suppliersList,
  });
}

// ==========================================
// 2. PROVIDERS
// ==========================================

final reportServiceProvider = Provider((ref) => ReportService());

// A. Filtro de Tiempo para Proveedores
final supplierFilterProvider = StateProvider<FilterState>((ref) => FilterState(period: 'month'));

// B. Provider de Datos (Lógica Principal)
final supplierReportProvider = FutureProvider.autoDispose<SupplierReportState>((ref) async {
  final filter = ref.watch(supplierFilterProvider);
  final service = ref.watch(reportServiceProvider);

  // 1. Llamada al Backend
  final rawData = await service.getSupplierAnalysis(
    filter.period,
    startDate: filter.customRange?.start,
    endDate: filter.customRange?.end,
  );

  final currencyFormat = NumberFormat("#,##0.00", "en_US");

  // 2. Helper para convertir Hex (#FFFFFF) a Color
  Color parseColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  // 3. Mapeo de la Lista de Proveedores
  final List<dynamic> listJson = rawData['suppliersList'] ?? [];
  final suppliersList = listJson.map((item) {
    return SupplierPerformanceRow(
      name: item['name'] ?? 'Desconocido',
      totalSpent: (item['totalSpent'] as num).toDouble(),
      purchaseCount: (item['purchaseCount'] as num).toInt(),
      percentage: (item['percentage'] as num).toDouble(),
    );
  }).toList();

  // 4. Mapeo del Gráfico de Pastel
  final List<dynamic> chartJson = rawData['spendingDistribution'] ?? [];
  final spendingDistribution = chartJson.map((item) {
    return AppPieChartData(
      item['name'],
      (item['value'] as num).toDouble(),
      parseColor(item['color']),
    );
  }).toList();

  // 5. Retornar Estado Final
  return SupplierReportState(
    totalSpentGlobal: currencyFormat.format((rawData['totalSpentGlobal'] as num).toDouble()),
    totalTransactions: (rawData['totalTransactions'] as num).toInt(),
    totalSuppliers: (rawData['totalSuppliers'] as num).toInt(),
    topSupplierName: rawData['topSupplierName'] ?? "N/A",
    suppliersList: suppliersList,
    spendingDistribution: spendingDistribution,
  );
});