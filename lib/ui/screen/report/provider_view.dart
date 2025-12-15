import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
// import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/providers/report/inventory_provider.dart'
    show AppPieChartData;
import 'package:sicv_flutter/ui/widgets/report/date_filter_selector.dart';

// Importamos el provider y el widget de filtro
import 'package:sicv_flutter/providers/report/supplier_provider.dart';

import '../../widgets/report/app_pie_chart.dart';
import 'package:sicv_flutter/ui/widgets/report/kpi_grid.dart';
import 'package:sicv_flutter/ui/widgets/report/kpi_card.dart';
// import 'package:sicv_flutter/core/theme/app_colors.dart';

class SupplierReportView extends ConsumerWidget {
  const SupplierReportView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Escuchamos los providers
    final supplierStateAsync = ref.watch(supplierReportProvider);
    final filterState = ref.watch(supplierFilterProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: supplierStateAsync.when(
        // CARGANDO
        loading: () => const Center(child: CircularProgressIndicator()),
        // ERROR
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                "Error: $err",
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
              TextButton(
                onPressed: () => ref.refresh(supplierReportProvider),
                child: const Text("Reintentar"),
              ),
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
              // Layout Responsivo
              if (MediaQuery.of(context).size.width > 900)
                _buildDesktopLayout(context, data)
              else
                _buildMobileLayout(context, data),
            ],
          ),
        ),
      ),
    );
  }

  // --- Header Actualizado con DateFilterSelector ---
  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    FilterState filterState,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Análisis de Proveedores",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Volumen de compras y distribución de gastos",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),

        // WIDGET DE FILTRO DE FECHAS
        DateFilterSelector(
          selectedFilter: filterState.period,
          selectedDateRange: filterState.customRange,
          onFilterChanged: (newFilter) {
            ref.read(supplierFilterProvider.notifier).state = filterState
                .copyWith(period: newFilter);
          },
          onDateRangeChanged: (newRange) {
            ref.read(supplierFilterProvider.notifier).state = filterState
                .copyWith(period: 'custom', customRange: newRange);
          },
        ),
      ],
    );
  }

  Widget _buildKpiGrid(BuildContext context, SupplierReportState data) {
    final kpis = [
      KpiData(
        "Gasto Total",
        "\$${data.totalSpentGlobal}",
        Icons.attach_money,
        Colors.green,
      ),
      KpiData(
        "Compras Realizadas",
        "${data.totalTransactions}",
        Icons.shopping_bag_outlined,
        Colors.lightBlue,
      ),
      KpiData(
        "Proveedores Activos",
        "${data.totalSuppliers}",
        Icons.storefront,
        Theme.of(context).primaryColor,
      ),
      KpiData(
        "Top Proveedor",
        data.topSupplierName,
        Icons.emoji_events_outlined,
        Colors.orange,
      ),
    ];

    return KpiGrid(kpis: kpis);
  }

  Widget _buildDesktopLayout(BuildContext context, SupplierReportState data) {
    return SizedBox(
      height: 550,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 4,
            child: _ChartContainer(
              title: "Distribución del Gasto",
              subtitle: "¿A quién le compro más? (% del dinero)",
              fillAvailableSpace: true,
              child: data.spendingDistribution.isEmpty
                  ? const Center(child: Text("Sin datos"))
                  : Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: AppPieChart(data: data.spendingDistribution),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 2,
                          child: _CostLegend(data: data.spendingDistribution),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 5,
            child: _ChartContainer(
              title: "Detalle por Proveedor",
              subtitle: "Historial de compras acumulado",
              fillAvailableSpace: true,
              child: data.suppliersList.isEmpty
                  ? const Center(child: Text("Sin datos"))
                  : _SupplierList(
                      suppliers: data.suppliersList,
                      isScrollable: true,
                    ),
            ),
          ),
        ],
      ),
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
  final bool fillAvailableSpace;

  const _ChartContainer({
    required this.title,
    required this.child,
    this.subtitle,
    this.fillAvailableSpace = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
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
            Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
          ],
          const SizedBox(height: 24),
          fillAvailableSpace ? Expanded(child: child) : child,
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
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                "${item.value.toStringAsFixed(0)}%",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
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
  final bool isScrollable;
  const _SupplierList({required this.suppliers, this.isScrollable = false});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: "\$");

    Widget list = ListView.separated(
      physics: isScrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      shrinkWrap: !isScrollable,
      itemCount: suppliers.length,
      separatorBuilder: (_, __) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final item = suppliers[index];
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.business,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
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
                            backgroundColor: Theme.of(
                              context,
                            ).scaffoldBackgroundColor,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${item.purchaseCount} compras",
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(fontSize: 11),
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  "Total",
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ],
            ),
          ],
        );
      },
    );

    return list;
  }
}
