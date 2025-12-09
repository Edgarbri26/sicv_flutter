import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:sicv_flutter/services/report_service.dart';

// --- CLASE DE ESTADO PARA EL FILTRO ---
class FilterState {
  final String period; // 'week', 'month', 'year', 'custom'
  final DateTimeRange? customRange;

  FilterState({this.period = 'month', this.customRange});

  FilterState copyWith({String? period, DateTimeRange? customRange}) {
    return FilterState(
      period: period ?? this.period,
      customRange: customRange ?? this.customRange,
    );
  }
}

// --- MODELOS DE UI (Sin cambios) ---
class EmployeePerformancePoint {
  final String name;
  final double salesCount;
  final double totalProfit;
  final Color color;
  EmployeePerformancePoint(this.name, this.salesCount, this.totalProfit, this.color);
}

class EmployeeChartData {
  final String name;
  final double value;
  final Color color;
  EmployeeChartData(this.name, this.value, this.color);
}

class EmployeeRow {
  final String name;
  final String role;
  final double profitGenerated;
  final String status;
  final String avatarUrl;
  EmployeeRow(this.name, this.role, this.profitGenerated, this.status, this.avatarUrl);
}

class EmployeeReportState {
  final String totalProfit;
  final int activeEmployees;
  final String topPerformer;
  final String avgProfit;
  final List<EmployeePerformancePoint> correlationData;
  final List<EmployeeChartData> chartData;
  final List<EmployeeRow> employees;

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

// --- PROVIDERS ACTUALIZADOS ---

// 1. Provider del Filtro (Ahora usa la clase FilterState)
final employeeFilterProvider = StateProvider<FilterState>((ref) => FilterState());

// 2. Provider Principal (Lógica de Negocio)
final employeeReportProvider = FutureProvider.autoDispose<EmployeeReportState>((ref) async {
  // Obtenemos el estado complejo del filtro
  final filterState = ref.watch(employeeFilterProvider);
  final service = ReportService();

  // 1. Llamada al Backend con los parámetros opcionales
  final rawData = await service.getEmployeePerformance(
    filterState.period,
    startDate: filterState.customRange?.start,
    endDate: filterState.customRange?.end,
  );

  // 2. Helper para colores
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
  
  final currencyFormat = NumberFormat("#,##0.00", "en_US");

  // 3. Variables para KPIs
  double sumProfit = 0;
  String bestEmployeeName = "N/A";
  double maxProfitFound = -1;

  List<EmployeePerformancePoint> correlationList = [];
  List<EmployeeChartData> chartList = [];
  List<EmployeeRow> employeeList = [];

  for (var item in rawData) {
    final name = item['name'] as String;
    final sales = (item['sales_count'] as num).toDouble();
    final profit = (item['total_profit'] as num).toDouble();
    final color = parseColor(item['color'] as String);

    sumProfit += profit;
    if (profit > maxProfitFound) {
      maxProfitFound = profit;
      bestEmployeeName = name;
    }

    correlationList.add(EmployeePerformancePoint(name, sales, profit, color));
    chartList.add(EmployeeChartData(name.split(' ')[0], sales, color));
    employeeList.add(EmployeeRow(
      name,
      "Vendedor",
      profit,
      profit > 0 ? "Activo" : "Sin Ventas", 
      "assets/avatar_placeholder.png", 
    ));
  }

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