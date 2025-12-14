import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/ui/widgets/report/kpi_grid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/providers/report/inventory_provider.dart';
import 'package:sicv_flutter/providers/report/summary_report_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sicv_flutter/ui/widgets/report/kpi_card.dart';
import 'package:sicv_flutter/ui/widgets/report/app_bar_chart.dart';
import 'package:sicv_flutter/ui/widgets/report/app_line_chart.dart';
import 'package:sicv_flutter/ui/widgets/report/app_line_chart_data.dart';
import 'package:sicv_flutter/ui/widgets/report/chart_container.dart';
import 'package:sicv_flutter/ui/widgets/report/date_filter_selector.dart';

// Cambiamos a ConsumerWidget para usar Riverpod
class ResumeView extends ConsumerWidget {
  const ResumeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // LEEMOS EL PROVIDER AQUÍ (Riverpod Style)
    final provider = ref.watch(summaryReportProvider);
    final inventoryProvider = ref.watch(inventoryReportProvider);

    final kpis = [
      KpiData(
        "Ventas Totales",
        "\$${provider.totalSales}",
        Icons.attach_money,
        AppColors.success,
      ),
      KpiData(
        "Compras",
        "\$ ${provider.totalPurchases}",
        Icons.shopping_bag_outlined,
        AppColors.hover,
      ),
      KpiData(
        "Ganancia Neta",
        "\$ ${provider.totalProfit}",
        Icons.account_balance_wallet_outlined,
        AppColors.primary,
      ),
      KpiData(
        "Alertas Stock",
        "${inventoryProvider.lowStockItems.length} Items",
        Icons.warning_amber_rounded,
        AppColors.edit,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderAndFilter(context, provider),
          const SizedBox(height: 24),

          KpiGrid(kpis: kpis),
          const SizedBox(height: 24),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return _buildDesktopLayout(context, provider);
              } else {
                return _buildMobileLayout(context, provider);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAndFilter(
    BuildContext context,
    SummaryReportProvider provider,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center, // Alineación vertical
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Resumen Ejecutivo",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
            ),
            Text(
              "Panorama general del negocio",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),

        // --- AQUÍ USAMOS EL WIDGET REUTILIZABLE ---
        DateFilterSelector(
          selectedFilter: provider.selectedFilter,
          selectedDateRange: provider.selectedDateRange,
          // Caso 1: Usuario elige Hoy, Semana, Mes...
          onFilterChanged: (newFilter) {
            provider.setFilter(newFilter);
          },
          // Caso 2: Usuario elige Rango Personalizado
          onDateRangeChanged: (newRange) {
            provider.setDateRange(newRange);
          },
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    SummaryReportProvider provider,
  ) {
    return Column(
      children: [
        ChartContainer(
          title: "Balance Financiero",
          subtitle: "Ventas vs Compras",
          child: AppLineChart(
            lineChartBarData: [
              AppLineChartData(data: provider.salesData, color: Colors.green),
            ],
            labels: provider.labels,
          ),
        ),
        ChartContainer(
          title: "Grafico de barras",
          child: AppBarChart(
            labels: provider.labels,
            barChartData: [
              ...provider.salesData.map(
                (spot) => BarChartGroupData(
                  x: spot.x.toInt(),
                  barRods: [
                    BarChartRodData(
                      toY: spot.y,
                      color: Colors.green,
                      width: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    SummaryReportProvider provider,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: ChartContainer(
            title: "Balance Financiero",
            height: 450,
            child: AppLineChart(
              lineChartBarData: [
                AppLineChartData(data: provider.salesData, color: Colors.green),
              ],
              labels: provider.labels,
            ),
          ),
        ),
      ],
    );
  }
}
