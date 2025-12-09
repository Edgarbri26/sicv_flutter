import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sicv_flutter/ui/widgets/report/app_pie_chart.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';

import '../../../providers/report/inventory_provider.dart' show AppPieChartData;

// --- 1. NUEVOS MODELOS DE DATOS ---

class SupplierReportState {
  final String totalSpentGlobal; // Dinero total gastado en compras
  final int totalTransactions;   // Cantidad total de compras registradas
  final int totalSuppliers;      // Cantidad de proveedores registrados
  final String topSupplierName;  // El proveedor al que más le has comprado

  // Distribución para la gráfica (Top 4 + Otros)
  final List<AppPieChartData> spendingDistribution;

  // Lista detallada de proveedores con sus métricas
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

class SupplierPerformanceRow {
  final String name;
  final double totalSpent;    // Cuánto le has comprado en total ($)
  final int purchaseCount;    // Cuántas veces le has comprado
  final double percentage;    // Qué % representa de tus gastos totales
  
  SupplierPerformanceRow({
    required this.name,
    required this.totalSpent,
    required this.purchaseCount,
    required this.percentage,
  });
}

// --- 2. PROVIDER SIMULADO (MOCK DATA) ---
// En el futuro, esto calculará los totales sumando tus compras filtradas por fecha.

final supplierReportProvider = Provider<SupplierReportState>((ref) {
  return SupplierReportState(
    totalSpentGlobal: "12,450.00",
    totalTransactions: 45,
    totalSuppliers: 8,
    topSupplierName: "Samsung",
    
    spendingDistribution: [
      AppPieChartData("Samsung", 45, const Color(0xFF5C6BC0)), 
      AppPieChartData("Apple", 30, const Color(0xFFAB47BC)), 
      AppPieChartData("Xiaomi", 15, const Color(0xFFFF7043)), 
      AppPieChartData("Logitech", 10, const Color(0xFF78909C)), 
    ],
    
    suppliersList: [
      SupplierPerformanceRow(name: "Samsung Electronics", totalSpent: 5602.50, purchaseCount: 12, percentage: 45),
      SupplierPerformanceRow(name: "Apple Distributor", totalSpent: 3735.00, purchaseCount: 8, percentage: 30),
      SupplierPerformanceRow(name: "Xiaomi Global", totalSpent: 1867.50, purchaseCount: 15, percentage: 15), // Compra mucho pero barato
      SupplierPerformanceRow(name: "Logitech Supply", totalSpent: 1245.00, purchaseCount: 10, percentage: 10),
    ],
  );
});

// --- 3. VISTA PRINCIPAL ---

class SupplierReportView extends ConsumerWidget {
  const SupplierReportView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(supplierReportProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            
            // KPIs de Volumen y Gasto
            _buildKpiGrid(context, data),
            
            const SizedBox(height: 24),
            
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return _buildDesktopLayout(context, data);
                } else {
                  return _buildMobileLayout(context, data);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Análisis de Proveedores", // Título cambiado
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          "Volumen de compras y distribución de gastos", // Descripción ajustada
          style: TextStyle(color: Colors.grey[500], fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildKpiGrid(BuildContext context, SupplierReportState data) {
    // KPIs enfocados en Gasto Histórico
    final kpis = [
      _KpiInfo(
        "Gasto Total",
        "\$${data.totalSpentGlobal}",
        Icons.attach_money,
        Colors.green, // Verde porque es dinero (aunque sea salida, es volumen)
      ),
      _KpiInfo(
        "Compras Realizadas",
        "${data.totalTransactions}",
        Icons.shopping_bag_outlined,
        Colors.blue,
      ),
      _KpiInfo(
        "Proveedores Activos",
        "${data.totalSuppliers}",
        Icons.storefront,
        Colors.indigo,
      ),
      _KpiInfo(
        "Top Proveedor",
        data.topSupplierName,
        Icons.emoji_events_outlined, // Copa o Estrella
        Colors.amber,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.0,
          ),
          itemCount: kpis.length,
          itemBuilder: (context, index) => _KpiCard(info: kpis[index]),
        );
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context, SupplierReportState data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna Izquierda: Gráfico
        Expanded(
          flex: 4,
          child: Column(
            children: [
              _ChartContainer(
                title: "Distribución del Gasto",
                subtitle: "¿A quién le compro más? (% del dinero)",
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 250,
                        child: AppPieChart(data: data.spendingDistribution),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: _CostLegend(data: data.spendingDistribution),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Columna Derecha: Lista Detallada
        Expanded(
          flex: 5,
          child: _ChartContainer(
            title: "Detalle por Proveedor",
            subtitle: "Historial de compras acumulado",
            child: _SupplierList(suppliers: data.suppliersList),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, SupplierReportState data) {
    return Column(
      children: [
        _ChartContainer(
          title: "Distribución del Gasto",
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 1.3,
                child: AppPieChart(data: data.spendingDistribution),
              ),
              const SizedBox(height: 20),
              _CostLegend(data: data.spendingDistribution),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _ChartContainer(
          title: "Detalle por Proveedor",
          child: _SupplierList(suppliers: data.suppliersList),
        ),
      ],
    );
  }
}

// --- WIDGETS AUXILIARES ---

class _ChartContainer extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _ChartContainer({
    required this.title,
    required this.child,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class _KpiInfo {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  _KpiInfo(this.title, this.value, this.icon, this.color);
}

class _KpiCard extends StatelessWidget {
  final _KpiInfo info;
  const _KpiCard({required this.info});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: info.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(info.icon, color: info.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  info.value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  info.title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CostLegend extends StatelessWidget {
  final List<AppPieChartData> data;
  const _CostLegend({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: data.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                "${item.value.toStringAsFixed(0)}%",
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _SupplierList extends StatelessWidget {
  final List<SupplierPerformanceRow> suppliers;
  const _SupplierList({required this.suppliers});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: "\$");

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: suppliers.length,
      separatorBuilder: (_, __) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final item = suppliers[index];
        return Row(
          children: [
            // Icono / Avatar
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.business, size: 20, color: Colors.blue.shade700),
            ),
            const SizedBox(width: 16),
            
            // Info Principal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Barra de progreso visual del % de gasto
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: item.percentage / 100,
                            minHeight: 6,
                            backgroundColor: Colors.grey[100],
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue.shade400),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${item.purchaseCount} compras",
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Monto Total
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currency.format(item.totalSpent),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "Total",
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}