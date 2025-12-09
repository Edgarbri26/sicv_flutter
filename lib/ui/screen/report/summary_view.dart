  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:sicv_flutter/providers/report/summary_report_provider.dart';
  import 'package:fl_chart/fl_chart.dart';
  import 'package:sicv_flutter/ui/widgets/kpi_card.dart';
import 'package:sicv_flutter/ui/widgets/report/app_bar_Chart.dart' show AppBarChart;
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

      return SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderAndFilter(context, provider),
            const SizedBox(height: 24),

            _buildKpiGrid(context, provider),
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
                      color: Colors.black87,
                    ),
              ),
              Text(
                "Panorama general del negocio",
                style: TextStyle(color: Colors.grey[600]),
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

    Widget _buildKpiGrid(BuildContext context, SummaryReportProvider provider) {
      final kpis = [
        KpiData(
          "Ventas Totales",
          "\$${provider.totalSales}",
          Icons.attach_money,
          Colors.green,
          "+12%",
        ),
        KpiData(
          "Compras",
          "\$ ${provider.totalPurchases}",
          Icons.shopping_bag_outlined,
          Colors.blue,
          "-5%",
        ),
        KpiData(
          "Ganancia Neta",
          "\$ ${provider.totalProfit}",
          Icons.account_balance_wallet_outlined,
          Colors.purple,
          "+8%",
        ),
        KpiData(
          "Alertas Stock",
          "8 Items",
          Icons.warning_amber_rounded,
          Colors.orange,
          "Urgente",
        ),
      ];

      return LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          int crossAxisCount = width < 600 ? 2 : 4;
          double aspectRatio = width < 600 ? 1.4 : 1.8;

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: aspectRatio,
            ),
            itemCount: kpis.length,
            itemBuilder: (context, index) => KpiCard(data: kpis[index]),
          );
        },
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
          const SizedBox(height: 20),
          ChartContainer(title: "Top Productos", child: _PieChartWidget()),
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
          const SizedBox(width: 20),
          Expanded(
            flex: 1,
            child: ChartContainer(
              title: "Top Productos",
              height: 450,
              child: _PieChartWidget(),
            ),
          ),
        ],
      );
    }
  }

  class _PieChartWidget extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: 40,
              color: Colors.blueAccent,
              radius: 50,
              title: '40%',
            ),
            PieChartSectionData(
              value: 30,
              color: Colors.orangeAccent,
              radius: 50,
              title: '30%',
            ),
            PieChartSectionData(
              value: 15,
              color: Colors.purpleAccent,
              radius: 50,
              title: '15%',
            ),
            PieChartSectionData(
              value: 15,
              color: Colors.grey[400],
              radius: 50,
              title: '15%',
            ),
          ],
        ),
      );
    }
  }
