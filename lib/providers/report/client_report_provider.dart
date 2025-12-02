import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart'; 
import 'package:sicv_flutter/services/report_service.dart';

// ==========================================
// 1. MODELOS DE UI
// ==========================================

// 1. Modelo de Correlación (Scatter Chart)
class ClientCorrelationPoint {
  final String name;
  final int ordersCount; 
  final double totalSpent; 
  
  ClientCorrelationPoint({
    required this.name, 
    required this.ordersCount, 
    required this.totalSpent,
  });
  
  // CORRECCIÓN APLICADA AQUÍ:
  factory ClientCorrelationPoint.fromJson(Map<String, dynamic> json) {
    return ClientCorrelationPoint(
      // Antes decía: json['client_name']
      name: json['name'] as String, 
      
      // Antes decía: json['orders_count']
      ordersCount: (json['ordersCount'] as num?)?.toInt() ?? 0,
      
      // Antes decía: json['total_spent']
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// 2. Modelo para el Gráfico de Barras (Top Clientes)
class ClientChartData {
  final String name;
  final double value; 
  final Color color;
  ClientChartData(this.name, this.value, this.color);
}

// 3. Modelo para la Lista Detallada
class ClientRow {
  final String name;
  final String type; 
  final double totalSpent;
  final String status; 
  ClientRow(this.name, this.type, this.totalSpent, this.status);
}

// --- 2. ESTADO ---
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

// 1. Filtro de Tiempo
final clientFilterProvider = StateProvider<String>((ref) => 'year'); 

// 2. Provider Principal (Lógica de Negocio)
final clientReportProvider = FutureProvider.autoDispose<ClientReportState>((ref) async {
  final filter = ref.watch(clientFilterProvider);
  final service = ref.watch(reportServiceProvider);

  // 1. Llamada a la API de Correlación
  final rawData = await service.fetchClientCorrelationFM(period: filter);

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

  // 4. Manejar estado vacío y KPIs
  final rawCount = rawData.length;
  if (rawCount == 0) {
      return ClientReportState(
        totalClients: "0", totalRevenue: currencyFormat.format(0), avgOrderValue: currencyFormat.format(0),
        topClientName: "N/A", correlationData: [], topClients: [], clientList: [],
      );
  }

  // 5. Cálculos Finales
  final avgOrderValueCalculated = sumTotalOrders > 0 ? sumTotalSpent / sumTotalOrders : 0;
  
  // 6. Mapeo a Listas Secundarias (Barras y Detalle)

  // Top 5 Clientes (para el gráfico de barras)
  final topClientsList = correlationList.take(5).map((point) {
    Color color = Colors.blue; 
    if (point.totalSpent == maxSpent) color = Colors.purple; 

    return ClientChartData(point.name.split(' ')[0], point.totalSpent, color);
  }).toList();

  // Lista Detallada (Asignación de Segmento)
  final detailList = correlationList.map((point) {
      String clientType = 'Regular';
      // Lógica simple de segmentación F-M
      if (point.totalSpent > 10000 && point.ordersCount > 10) clientType = 'VIP';
      else if (point.ordersCount == 1) clientType = 'Nuevo';
      else if (point.totalSpent < 500 && point.ordersCount > 5) clientType = 'Commodity';
      
      // Estado (Activo si tiene alguna venta en el periodo)
      String status = (point.totalSpent > 0 || point.ordersCount > 0) ? 'Activo' : 'Inactivo'; 

      return ClientRow(point.name, clientType, point.totalSpent, status); 
  }).toList();


  return ClientReportState(
    totalClients: rawCount.toString(),
    totalRevenue: currencyFormat.format(sumTotalSpent),
    // Usamos la variable corregida
    avgOrderValue: currencyFormat.format(avgOrderValueCalculated),
    topClientName: topClient,
    
    correlationData: correlationList,
    topClients: topClientsList,
    clientList: detailList,
  );
});