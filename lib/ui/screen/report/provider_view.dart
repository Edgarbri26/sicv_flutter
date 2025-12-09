import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/providers/report/inventory_provider.dart' show AppPieChartData;
import 'package:sicv_flutter/ui/widgets/report/date_filter_selector.dart';

// Importamos el provider y el widget de filtro
import 'package:sicv_flutter/providers/report/supplier_provider.dart';

import '../../widgets/report/app_pie_chart.dart';

class SupplierReportView extends ConsumerWidget {
  const SupplierReportView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Escuchamos los providers
    final supplierStateAsync = ref.watch(supplierReportProvider);
    final filterState = ref.watch(supplierFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: supplierStateAsync.when(
        // CARGANDO
        loading: () => const Center(child: CircularProgressIndicator()),
        // ERROR
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text("Error: $err", style: const TextStyle(color: Colors.grey)),
              TextButton(
                onPressed: () => ref.refresh(supplierReportProvider),
                child: const Text("Reintentar"),
              )
            ],
          ),
        ),
        // DATA
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con Filtro
              _buildHeader(context, ref, filterState),
              const SizedBox(height: 32),

              // Grid de KPIs
              _buildKpiGrid(context, data),
              const SizedBox(height: 24),

              // Layout Responsivo
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
      ),
    );
  }

  // --- Header Actualizado con DateFilterSelector ---
  Widget _buildHeader(BuildContext context, WidgetRef ref, FilterState filterState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Análisis de Proveedores",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              "Volumen de compras y distribución de gastos",
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
        
        // WIDGET DE FILTRO DE FECHAS
        DateFilterSelector(
          selectedFilter: filterState.period,
          selectedDateRange: filterState.customRange,
          onFilterChanged: (newFilter) {
            ref.read(supplierFilterProvider.notifier).state =
                filterState.copyWith(period: newFilter);
          },
          onDateRangeChanged: (newRange) {
            ref.read(supplierFilterProvider.notifier).state =
                filterState.copyWith(period: 'custom', customRange: newRange);
          },
        ),
      ],
    );
  }

  Widget _buildKpiGrid(BuildContext context, SupplierReportState data) {
    final kpis = [
      _KpiInfo(
        "Gasto Total",
        "\$${data.totalSpentGlobal}",
        Icons.attach_money,
        Colors.green,
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
        Icons.emoji_events_outlined,
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
        Expanded(
          flex: 4,
          child: Column(
            children: [
              _ChartContainer(
                title: "Distribución del Gasto",
                subtitle: "¿A quién le compro más? (% del dinero)",
                child: data.spendingDistribution.isEmpty
                    ? const Center(child: Text("Sin datos"))
                    : Row(
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
        Expanded(
          flex: 5,
          child: _ChartContainer(
            title: "Detalle por Proveedor",
            subtitle: "Historial de compras acumulado",
            child: data.suppliersList.isEmpty
                ? const Center(child: Text("Sin datos"))
                : _SupplierList(suppliers: data.suppliersList),
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
          child: data.spendingDistribution.isEmpty
              ? const Center(child: Text("Sin datos"))
              : Column(
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
          child: data.suppliersList.isEmpty
              ? const Center(child: Text("Sin datos"))
              : _SupplierList(suppliers: data.suppliersList),
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.business, size: 20, color: Colors.blue.shade700),
            ),
            const SizedBox(width: 16),
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