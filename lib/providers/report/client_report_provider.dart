import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart'; 
import 'package:sicv_flutter/services/report_service.dart';

// ==========================================
// 0. CLASE DE ESTADO PARA EL FILTRO 
// (Si ya la tienes en un archivo 'shared', impórtala y borra esta definición)
// ==========================================
class FilterState {
  final String period; // 'week', 'month', 'year', 'custom'
  final DateTimeRange? customRange;

  FilterState({this.period = 'year', this.customRange});

  FilterState copyWith({String? period, DateTimeRange? customRange}) {
    return FilterState(
      period: period ?? this.period,
      customRange: customRange ?? this.customRange,
    );
  }
}

// ==========================================
// 1. MODELOS DE UI
// ==========================================

class ClientCorrelationPoint {
  final String name;
  final int ordersCount; 
  final double totalSpent; 
  
  ClientCorrelationPoint({
    required this.name, 
    required this.ordersCount, 
    required this.totalSpent,
  });
  
  factory ClientCorrelationPoint.fromJson(Map<String, dynamic> json) {
    return ClientCorrelationPoint(
      name: json['name'] as String, 
      ordersCount: (json['ordersCount'] as num?)?.toInt() ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ClientChartData {
  final String name;
  final double value; 
  final Color color;
  ClientChartData(this.name, this.value, this.color);
}

class ClientRow {
  final String name;
  final String type; 
  final double totalSpent;
  final String status; 
  ClientRow(this.name, this.type, this.totalSpent, this.status);
}

// --- 2. ESTADO DEL REPORTE ---
class ClientReportState {
  final String totalClients;
  final String totalRevenue;
  final String avgOrderValue;
  final String topClientName;
  
  final List<ClientCorrelationPoint> correlationData; 
  final List<ClientChartData> topClients; 
  final List<ClientRow> clientList; 

  ClientReportState({
    required this.totalClients,
    required this.totalRevenue,
    required this.avgOrderValue,
    required this.topClientName,
    required this.correlationData,
    required this.topClients,
    required this.clientList,
  });
}

// --- 3. PROVIDERS ---

final reportServiceProvider = Provider((ref) => ReportService());

// 1. Filtro de Tiempo (ACTUALIZADO: Ahora usa FilterState)
final clientFilterProvider = StateProvider<FilterState>((ref) => FilterState(period: 'year')); 

// 2. Provider Principal (Lógica de Negocio)
final clientReportProvider = FutureProvider.autoDispose<ClientReportState>((ref) async {
  // A. Leemos el estado complejo del filtro
  final filterState = ref.watch(clientFilterProvider);
  final service = ref.watch(reportServiceProvider);

  // B. Llamada a la API pasando fechas si existen
  final rawData = await service.fetchClientCorrelationFM(
    period: filterState.period,
    startDate: filterState.customRange?.start,
    endDate: filterState.customRange?.end,
  );

  // 2. Setup Helpers y Acumuladores
  final currencyFormat = NumberFormat("#,##0.00", "en_US");
  double sumTotalSpent = 0;
  double sumTotalOrders = 0;
  String topClient = "N/A";
  double maxSpent = -1;

  // 3. Procesamiento y Cálculo de KPIs
  final correlationList = rawData; 
  
  for (var point in correlationList) {
    sumTotalSpent += point.totalSpent;
    sumTotalOrders += point.ordersCount;
    
    if (point.totalSpent > maxSpent) {
      maxSpent = point.totalSpent;
      topClient = point.name;
    }
  }

  // 4. Manejar estado vacío
  final rawCount = rawData.length;
  if (rawCount == 0) {
      return ClientReportState(
        totalClients: "0", totalRevenue: currencyFormat.format(0), avgOrderValue: currencyFormat.format(0),
        topClientName: "N/A", correlationData: [], topClients: [], clientList: [],
      );
  }

  // 5. Cálculos Finales
  final avgOrderValueCalculated = sumTotalOrders > 0 ? sumTotalSpent / sumTotalOrders : 0;
  
  // 6. Mapeo a Listas Secundarias

  // Top 5 Clientes
  final topClientsList = correlationList.take(5).map((point) {
    Color color = Colors.blue; 
    if (point.totalSpent == maxSpent) color = Colors.purple; 

    return ClientChartData(point.name.split(' ')[0], point.totalSpent, color);
  }).toList();

  // Lista Detallada
  final detailList = correlationList.map((point) {
      String clientType = 'Regular';
      if (point.totalSpent > 10000 && point.ordersCount > 10) clientType = 'VIP';
      else if (point.ordersCount == 1) clientType = 'Nuevo';
      else if (point.totalSpent < 500 && point.ordersCount > 5) clientType = 'Commodity';
      
      String status = (point.totalSpent > 0 || point.ordersCount > 0) ? 'Activo' : 'Inactivo'; 

      return ClientRow(point.name, clientType, point.totalSpent, status); 
  }).toList();

  return ClientReportState(
    totalClients: rawCount.toString(),
    totalRevenue: currencyFormat.format(sumTotalSpent),
    avgOrderValue: currencyFormat.format(avgOrderValueCalculated),
    topClientName: topClient,
    correlationData: correlationList,
    topClients: topClientsList,
    clientList: detailList,
  );
});