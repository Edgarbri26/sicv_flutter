import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart'; 
import 'package:sicv_flutter/services/report_service.dart';
import 'package:sicv_flutter/models/report/inventory_efficiency.dart';

// --- CLASES DE DATOS ---
class CategoryData {
  final String name;
  final double value; // Aquí guardaremos el PORCENTAJE para el gráfico
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
  final List<CategoryData> categoryDistribution; // AHORA ES REAL
  
  // Datos Mock (Pendientes de endpoint)
  final int lowStockAlerts;
  final String monthlyTurnover;
  final List<ProductMetric> topProducts;
  final List<StockAlert> lowStockItems;

  InventoryState({
    required this.efficiencyData,
    required this.totalInventoryValue,
    required this.totalItems,
    required this.categoryDistribution,
    this.lowStockAlerts = 5,
    this.monthlyTurnover = "18%",
    this.topProducts = const [],
    this.lowStockItems = const [],
  });
}

// --- PROVIDER ---

final inventoryFilterProvider = StateProvider<String>((ref) => 'month');

final inventoryReportProvider = FutureProvider.autoDispose<InventoryState>((ref) async {
  final filter = ref.watch(inventoryFilterProvider);
  final service = ReportService();

  // EJECUTAMOS 4 PETICIONES EN PARALELO
  final results = await Future.wait([
    service.getInventoryEfficiency(filter), // [0]
    service.getInventoryValue(),            // [1]
    service.getTotalItems(),                // [2]
    service.getInventoryByCategory(),       // [3] NUEVO
  ]);

  // Extraemos resultados
  final efficiencyData = results[0] as List<InventoryEfficiencyPoint>;
  final inventoryValue = results[1] as double;
  final totalItems = results[2] as int;
  final categoryRawData = results[3] as List<Map<String, dynamic>>;

  // Helper para convertir Hex String (#RRGGBB) a Color
  Color parseColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  // Mapeamos la respuesta del backend a CategoryData
  final categoryDistribution = categoryRawData.map((item) {
    return CategoryData(
      item['name'] as String,
      (item['percentage'] as num).toDouble(), // Usamos el porcentaje para el gráfico
      parseColor(item['color'] as String),
    );
  }).toList();

  final currencyFormat = NumberFormat("#,##0.00", "en_US");

  return InventoryState(
    efficiencyData: efficiencyData,
    totalInventoryValue: currencyFormat.format(inventoryValue),
    totalItems: totalItems,
    categoryDistribution: categoryDistribution, // Datos reales inyectados
    
    // Mocks restantes
    topProducts: [
      ProductMetric("Laptop Dell G15", 120, 0.9),
      ProductMetric("iPhone 13 Pro", 95, 0.75),
      ProductMetric("Monitor LG 24'", 80, 0.6),
    ],
    lowStockItems: [
      StockAlert("Adaptador HDMI", 2, "Crítico"),
      StockAlert("Funda iPhone 13", 4, "Bajo"),
    ],
  );
});