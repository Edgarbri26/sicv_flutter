import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sicv_flutter/services/report_service.dart'; // Importa tu servicio
import 'package:sicv_flutter/models/report/inventory_efficiency.dart';

// --- CLASES DE DATOS AUXILIARES (Para lo que aún no tiene endpoint) ---
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
  
  // Datos Mock (Hasta que tengas endpoints para ellos)
  final String totalInventoryValue;
  final int totalItems;
  final int lowStockAlerts;
  final String monthlyTurnover;
  final List<CategoryData> categoryDistribution;
  final List<ProductMetric> topProducts;
  final List<StockAlert> lowStockItems;

  InventoryState({
    required this.efficiencyData,
    this.totalInventoryValue = "45,230.00", // Mock
    this.totalItems = 1450, // Mock
    this.lowStockAlerts = 5, // Mock
    this.monthlyTurnover = "18%", // Mock
    this.categoryDistribution = const [], // Mock se llena abajo
    this.topProducts = const [], // Mock se llena abajo
    this.lowStockItems = const [], // Mock se llena abajo
  });
}

// --- PROVIDERS ---

// 1. Provider para el filtro de tiempo (week, month, year)
final inventoryFilterProvider = StateProvider<String>((ref) => 'month');

// 2. Provider que trae los datos
final inventoryReportProvider = FutureProvider.autoDispose<InventoryState>((ref) async {
  final filter = ref.watch(inventoryFilterProvider);
  final service = ReportService();

  // 1. Obtenemos los datos reales del backend
  final efficiencyData = await service.getInventoryEfficiency(filter);

  // 2. Retornamos el estado mezclando datos reales y mocks
  return InventoryState(
    efficiencyData: efficiencyData,
    
    // --- MOCKS (Puedes conectar más endpoints aquí luego) ---
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