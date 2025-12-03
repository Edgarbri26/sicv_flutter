import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:sicv_flutter/services/report_service.dart';

// --- MODELOS DE UI ---

class EmployeePerformancePoint {
  final String name;
  final double salesCount;  // Eje X
  final double totalProfit; // Eje Y
  final Color color;
  EmployeePerformancePoint(this.name, this.salesCount, this.totalProfit, this.color);
}

class EmployeeChartData {
  final String name;
  final double value; // Ventas para las barras
  final Color color;
  EmployeeChartData(this.name, this.value, this.color);
}

class EmployeeRow {
  final String name;
  final String role;
  final double profitGenerated; // Ganancia generada
  final String status;
  final String avatarUrl;
  EmployeeRow(this.name, this.role, this.profitGenerated, this.status, this.avatarUrl);
}

// --- ESTADO ---
class EmployeeReportState {
  final String totalProfit;      // KPI: Ganancia Total
  final int activeEmployees;     // KPI: Cantidad Empleados
  final String topPerformer;     // KPI: Mejor Empleado
  final String avgProfit;        // KPI: Promedio Ganancia
  
  final List<EmployeePerformancePoint> correlationData; // Gráfico Dispersión
  final List<EmployeeChartData> chartData;              // Gráfico Barras
  final List<EmployeeRow> employees;                    // Lista Detallada

  EmployeeReportState({
    required this.totalProfit,
    required this.activeEmployees,
    required this.topPerformer,
    required this.avgProfit,
    required this.correlationData,
    required this.chartData,
    required this.employees,
  });
}

// --- PROVIDERS ---

// 1. Filtro de Tiempo (week, month, year)
final employeeFilterProvider = StateProvider<String>((ref) => 'month');

// 2. Provider Principal (Lógica de Negocio)
final employeeReportProvider = FutureProvider.autoDispose<EmployeeReportState>((ref) async {
  final filter = ref.watch(employeeFilterProvider);
  final service = ReportService();

  // 1. Llamada al Backend
  final rawData = await service.getEmployeePerformance(filter);

  // 2. Helper para colores Hex (#RRGGBB -> Color)
  Color parseColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.grey; // Fallback por seguridad
    }
  }
  
  final currencyFormat = NumberFormat("#,##0.00", "en_US");

  // 3. Variables para KPIs
  double sumProfit = 0;
  String bestEmployeeName = "N/A";
  double maxProfitFound = -1;

  // 4. Procesamiento de Listas
  List<EmployeePerformancePoint> correlationList = [];
  List<EmployeeChartData> chartList = [];
  List<EmployeeRow> employeeList = [];

  for (var item in rawData) {
    final name = item['name'] as String;
    final sales = (item['sales_count'] as num).toDouble();
    final profit = (item['total_profit'] as num).toDouble();
    final color = parseColor(item['color'] as String);

    // Acumular KPIs
    sumProfit += profit;
    if (profit > maxProfitFound) {
      maxProfitFound = profit;
      bestEmployeeName = name;
    }

    // A) Datos para Gráfico de Dispersión
    correlationList.add(EmployeePerformancePoint(name, sales, profit, color));

    // B) Datos para Gráfico de Barras (Usamos solo el primer nombre para que quepa)
    chartList.add(EmployeeChartData(name.split(' ')[0], sales, color));

    // C) Datos para Lista de Empleados
    employeeList.add(EmployeeRow(
      name,
      "Vendedor", // Placeholder (podrías traer el role del backend si quisieras)
      profit,
      profit > 0 ? "Activo" : "Sin Ventas", 
      "assets/avatar_placeholder.png", 
    ));
  }

  // Calcular promedio
  double average = rawData.isNotEmpty ? sumProfit / rawData.length : 0;

  return EmployeeReportState(
    totalProfit: currencyFormat.format(sumProfit),
    activeEmployees: rawData.length,
    topPerformer: bestEmployeeName,
    avgProfit: currencyFormat.format(average),
    correlationData: correlationList,
    chartData: chartList,
    employees: employeeList,
  );
});