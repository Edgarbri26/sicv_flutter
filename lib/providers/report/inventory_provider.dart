import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart'; // Asegúrate de tener intl en pubspec.yaml para formatear moneda
import 'package:sicv_flutter/services/report_service.dart';
import 'package:sicv_flutter/models/report/inventory_efficiency.dart';

// --- CLASES DE DATOS AUXILIARES ---
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
  final String totalInventoryValue; // Ahora viene del backend
  final int totalItems;             // Ahora viene del backend
  
  // Datos Mock (Aún pendientes de endpoint)
  final int lowStockAlerts;
  final String monthlyTurnover;
  final List<CategoryData> categoryDistribution;
  final List<ProductMetric> topProducts;
  final List<StockAlert> lowStockItems;

  InventoryState({
    required this.efficiencyData,
    required this.totalInventoryValue,
    required this.totalItems,
    this.lowStockAlerts = 5, // Mock
    this.monthlyTurnover = "18%", // Mock
    this.categoryDistribution = const [],
    this.topProducts = const [],
    this.lowStockItems = const [],
  });
}

// --- PROVIDERS ---

final inventoryFilterProvider = StateProvider<String>((ref) => 'month');

final inventoryReportProvider = FutureProvider.autoDispose<InventoryState>((ref) async {
  final filter = ref.watch(inventoryFilterProvider);
  final service = ReportService();

  // EJECUTAMOS 3 PETICIONES EN PARALELO PARA MAYOR VELOCIDAD
  final results = await Future.wait([
    service.getInventoryEfficiency(filter), // [0] Lista de Puntos
    service.getInventoryValue(),            // [1] Valor en USD (double)
    service.getTotalItems(),                // [2] Total Items (int)
  ]);

  // Extraemos los resultados
  final efficiencyData = results[0] as List<InventoryEfficiencyPoint>;
  final inventoryValue = results[1] as double;
  final totalItems = results[2] as int;

  // Formateador para moneda (ej: 1,234.56)
  final currencyFormat = NumberFormat("#,##0.00", "en_US");

  return InventoryState(
    // Inyectamos datos reales
    efficiencyData: efficiencyData,
    totalInventoryValue: currencyFormat.format(inventoryValue),
    totalItems: totalItems,
    
    // --- MOCKS ---
    categoryDistribution: [
      CategoryData("Electrónica", 40, const Color(0xFF6366F1)),
      CategoryData("Ropa", 30, const Color(0xFF3B82F6)),
      CategoryData("Hogar", 15, const Color(0xFF10B981)),
      CategoryData("Otros", 15, const Color(0xFF9CA3AF)),
    ],
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