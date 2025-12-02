import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:sicv_flutter/services/report_service.dart';
import 'package:sicv_flutter/models/report/inventory_efficiency.dart';

// --- CLASES DE DATOS ---
class CategoryData {
  final String name;
  final double value;
  final Color color;
  CategoryData(this.name, this.value, this.color);
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

// --- ESTADO COMBINADO ---
class InventoryState {
  // Datos Reales
  final List<InventoryEfficiencyPoint> efficiencyData;
  final String totalInventoryValue;
  final int totalItems;
  final List<CategoryData> categoryDistribution;
  final List<ProductMetric> topProducts; // <--- AHORA ES REAL
  
  // Datos Mock (Pendientes de endpoint)
  final int lowStockAlerts;
  final String monthlyTurnover;
  final List<StockAlert> lowStockItems;

  InventoryState({
    required this.efficiencyData,
    required this.totalInventoryValue,
    required this.totalItems,
    required this.categoryDistribution,
    required this.topProducts,
    this.lowStockAlerts = 5,
    this.monthlyTurnover = "18%",
    this.lowStockItems = const [],
  });
}

// --- PROVIDER ---

final inventoryFilterProvider = StateProvider<String>((ref) => 'month');

final inventoryReportProvider = FutureProvider.autoDispose<InventoryState>((
  ref,
) async {
  final filter = ref.watch(inventoryFilterProvider);
  final service = ReportService();

  // EJECUTAMOS 5 PETICIONES EN PARALELO
  final results = await Future.wait([
    service.getInventoryEfficiency(filter),   // [0] Scatter Chart
    service.getInventoryValue(),              // [1] Valor USD
    service.getTotalItems(),                  // [2] Total Items
    service.getInventoryByCategory(),         // [3] Pie Chart
    service.getTopSellingProducts(filter),    // [4] NUEVO: Top List
  ]);

  // 1. Extraemos resultados
  final efficiencyData = results[0] as List<InventoryEfficiencyPoint>;
  final inventoryValue = results[1] as double;
  final totalItems = results[2] as int;
  final categoryRawData = results[3] as List<Map<String, dynamic>>;
  final topProductsRawData = results[4] as List<Map<String, dynamic>>; // <--- NUEVO

  // 2. Procesamiento de Colores para Categorías
  Color parseColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  final categoryDistribution = categoryRawData.map((item) {
    return CategoryData(
      item['name'] as String,
      (item['percentage'] as num).toDouble(),
      parseColor(item['color'] as String),
    );
  }).toList();

  // 3. Procesamiento de Top Productos (NUEVO)
  final topProducts = topProductsRawData.map((item) {
    return ProductMetric(
      item['name'] as String,
      item['soldCount'] as int,
      (item['percentage'] as num).toDouble(), // Aseguramos que sea double (0.0 - 1.0)
    );
  }).toList();

  final currencyFormat = NumberFormat("#,##0.00", "en_US");

  return InventoryState(
    efficiencyData: efficiencyData,
    totalInventoryValue: currencyFormat.format(inventoryValue),
    totalItems: totalItems,
    categoryDistribution: categoryDistribution,
    topProducts: topProducts, // <--- Inyectamos datos reales
    
    // Mocks restantes (Solo falta el de Alertas de Stock)
    lowStockItems: [
      StockAlert("Adaptador HDMI", 2, "Crítico"),
      StockAlert("Funda iPhone 13", 4, "Bajo"),
    ],
  );
});
