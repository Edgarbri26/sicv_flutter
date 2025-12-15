import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';

// 1. IMPORTA TU PROVIDER
import 'package:sicv_flutter/providers/report/employee_provider.dart';
import 'package:sicv_flutter/ui/widgets/report/chart_container.dart';

// 2. EL BENDITO IMPORT SOLICITADO (Asegúrate de que la carpeta sea 'rerport' o corrige a 'report')
import 'package:sicv_flutter/ui/widgets/report/date_filter_selector.dart';
import 'package:sicv_flutter/ui/widgets/report/kpi_grid.dart';
import 'package:sicv_flutter/ui/widgets/report/kpi_card.dart';

class EmployeeReportView extends ConsumerWidget {
  const EmployeeReportView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el estado del provider de datos
    final employeeStateAsync = ref.watch(employeeReportProvider);

    // Escuchamos el estado del FILTRO (Ahora es FilterState, no String)
    final filterState = ref.watch(employeeFilterProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: employeeStateAsync.when(
        // ESTADO: CARGANDO
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        // ESTADO: ERROR
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error al cargar reporte de personal:\n$err',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => ref.refresh(employeeReportProvider),
                icon: const Icon(Icons.refresh),
                label: const Text("Reintentar"),
              ),
            ],
          ),
        ),
        // ESTADO: DATOS LISTOS
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con el Widget de Filtro Importado
              _buildHeader(context, ref, filterState),
              const SizedBox(height: 32),

              // Grid de KPIs
              _buildKpiGrid(context, data),

              const SizedBox(height: 24),

              // Layout Adaptativo (Gráficos y Lista)
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

  // --- Header Actualizado con el Widget Importado ---
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
              "Reporte de Personal",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Desempeño, comisiones y actividad reciente",
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontSize: 14,
              ),
            ),
          ],
        ),

        // WIDGET CORREGIDO
        DateFilterSelector(
          // 1. Pasamos los valores actuales del estado (FilterState)
          selectedFilter: filterState.period,
          selectedDateRange: filterState.customRange,

          // 2. Caso: Usuario cambia el filtro (week, month, year, custom)
          onFilterChanged: (newFilter) {
            // Actualizamos el estado copiando el anterior y cambiando el periodo
            ref.read(employeeFilterProvider.notifier).state = filterState
                .copyWith(period: newFilter);
          },

          // 3. Caso: Usuario selecciona fechas en el calendario
          onDateRangeChanged: (newRange) {
            // Forzamos periodo 'custom' y guardamos el rango
            ref.read(employeeFilterProvider.notifier).state = filterState
                .copyWith(period: 'custom', customRange: newRange);
          },
        ),
      ],
    );
  }

  Widget _buildKpiGrid(BuildContext context, EmployeeReportState data) {
    final kpis = [
      KpiData(
        "Empleados Activos",
        "${data.activeEmployees}",
        Icons.people_alt_outlined,
        AppColors.info,
      ),
      KpiData(
        "Mejor Desempeño",
        data.topPerformer,
        Icons.star_border,
        Colors.amber,
      ),
      KpiData(
        "Ganancia Total",
        "\$${data.totalProfit}",
        Icons.attach_money,
        AppColors.success,
      ),
      KpiData(
        "Promedio Ganancia",
        "\$${data.avgProfit}",
        Icons.bar_chart,
        Colors.purple,
      ),
    ];

    return KpiGrid(kpis: kpis);
  }

  // --- LAYOUTS ---

  Widget _buildDesktopLayout(BuildContext context, EmployeeReportState data) {
    return Column(
      children: [
        SizedBox(
          height: 550,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Gráfico de Barras
              Expanded(
                flex: 1,
                child: ChartContainer(
                  title: "Ventas por Empleado",
                  subtitle: "Cantidad de ventas realizadas",
                  fillAvailableSpace: true,
                  child: data.chartData.isEmpty
                      ? const Center(
                          child: Text(
                            "Sin datos de ventas",
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : _EmployeeBarChart(data: data.chartData),
                ),
              ),
              const SizedBox(width: 24),
              // Gráfico de Correlación
              Expanded(
                flex: 1,
                child: ChartContainer(
                  title: "Análisis de Desempeño: Cantidad vs Ganancia",
                  subtitle:
                      "Relación entre el esfuerzo de venta y el retorno financiero",
                  fillAvailableSpace: true,
                  child: Column(
                    children: [
                      // --- GUÍA DE INTERPRETACIÓN ---
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildGuideItem(
                              Icons.attach_money,
                              AppColors.success,
                              "Eje Vertical",
                              "Rentabilidad",
                            ),
                            _buildGuideItem(
                              Icons.shopping_cart,
                              AppColors.info,
                              "Eje Horizontal",
                              "Volumen",
                            ),
                            _buildGuideItem(
                              Icons.trending_up,
                              AppColors.edit,
                              "Objetivo",
                              "Sup. Derecha",
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: data.correlationData.isEmpty
                            ? const Center(
                                child: Text(
                                  "Sin datos de correlación",
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              )
                            : _CorrelationChart(data: data.correlationData),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Lista de Empleados
        ChartContainer(
          title: "Detalle de Equipo",
          subtitle: "Estado y ganancias generadas",
          child: data.employees.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "No hay empleados con ventas",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              : _EmployeeList(employees: data.employees),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, EmployeeReportState data) {
    return Column(
      children: [
        ChartContainer(
          title: "Correlación: Cantidad vs Ganancia",
          subtitle: "Rendimiento individual",
          child: AspectRatio(
            aspectRatio: 1.3,
            child: data.correlationData.isEmpty
                ? const Center(
                    child: Text(
                      "Sin datos",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : _CorrelationChart(data: data.correlationData),
          ),
        ),
        const SizedBox(height: 24),
        ChartContainer(
          title: "Ventas por Empleado",
          subtitle: "Cantidad total",
          child: AspectRatio(
            aspectRatio: 1.5,
            child: data.chartData.isEmpty
                ? const Center(
                    child: Text(
                      "Sin datos",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : _EmployeeBarChart(data: data.chartData),
          ),
        ),
        const SizedBox(height: 24),
        ChartContainer(
          title: "Detalle de Equipo",
          subtitle: "Estado actual",
          child: data.employees.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "No hay empleados con ventas",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              : _EmployeeList(employees: data.employees),
        ),
      ],
    );
  }
}

class _EmployeeBarChart extends StatelessWidget {
  final List<EmployeeChartData> data;
  const _EmployeeBarChart({required this.data});
  @override
  Widget build(BuildContext context) {
    double maxY = 0;
    for (var item in data) {
      if (item.value > maxY) maxY = item.value;
    }
    maxY = (maxY == 0 ? 10 : maxY) * 1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => AppColors.primary,
            tooltipBorderRadius: BorderRadius.circular(8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                BarTooltipItem(
                  rod.toY.toInt().toString(),
                  const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                if (val.toInt() >= 0 && val.toInt() < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      data[val.toInt()].name,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 5,
          getDrawingHorizontalLine: (val) => FlLine(
            color: AppColors.border.withValues(alpha: 0.1),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data
            .asMap()
            .entries
            .map(
              (e) => BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: e.value.value,
                    color: e.value.color,
                    width: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

Widget _buildGuideItem(IconData icon, Color color, String label, String value) {
  return Column(
    children: [
      Icon(icon, size: 18, color: color),
      const SizedBox(height: 4),
      Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
      Text(
        value,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      ),
    ],
  );
}

class _CorrelationChart extends StatelessWidget {
  final List<EmployeePerformancePoint> data;
  const _CorrelationChart({required this.data});
  @override
  Widget build(BuildContext context) {
    double maxX = 0;
    double maxY = 0;
    for (var p in data) {
      if (p.salesCount > maxX) maxX = p.salesCount;
      if (p.totalProfit > maxY) maxY = p.totalProfit;
    }
    maxX = (maxX == 0 ? 10 : maxX) * 1.2;
    maxY = (maxY == 0 ? 100 : maxY) * 1.2;

    return ScatterChart(
      ScatterChartData(
        minX: 0,
        maxX: maxX,
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          getDrawingHorizontalLine: (val) =>
              FlLine(color: AppColors.border.withValues(alpha: 0.1)),
          getDrawingVerticalLine: (val) =>
              FlLine(color: AppColors.border.withValues(alpha: 0.1)),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            axisNameWidget: const Text(
              "Ganancia (\$)",
              style: TextStyle(fontSize: 10),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (val, meta) => Text(
                val >= 1000
                    ? "${(val / 1000).toStringAsFixed(0)}k"
                    : "${val.toInt()}",
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: const Text(
              "Cantidad de Ventas",
              style: TextStyle(fontSize: 10),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) => Text(
                "${val.toInt()}",
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppColors.border.withValues(alpha: 0.2)),
        ),
        scatterSpots: data.map((point) {
          return ScatterSpot(
            point.salesCount,
            point.totalProfit,
            dotPainter: FlDotCirclePainter(
              color: point.color,
              radius: 8,
              strokeWidth: 0,
            ),
          );
        }).toList(),
        scatterTouchData: ScatterTouchData(
          enabled: true,
          touchTooltipData: ScatterTouchTooltipData(
            getTooltipColor: (spot) => AppColors.primary,
            getTooltipItems: (ScatterSpot spot) {
              try {
                final employee = data.firstWhere(
                  (e) =>
                      (e.salesCount - spot.x).abs() < 0.1 &&
                      (e.totalProfit - spot.y).abs() < 0.1,
                  orElse: () => EmployeePerformancePoint(
                    "Desconocido",
                    0,
                    0,
                    AppColors.disabled,
                  ),
                );
                return XAxisTooltipItem(
                  text:
                      "${employee.name}\nVentas: ${spot.x.toInt()}\nGanancia: \$${spot.y.toStringAsFixed(0)}",
                  textStyle: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                );
              } catch (e) {
                return null;
              }
            },
          ),
        ),
      ),
    );
  }
}

class XAxisTooltipItem extends ScatterTooltipItem {
  XAxisTooltipItem({required String text, required TextStyle textStyle})
    : super(text, textStyle: textStyle, bottomMargin: 10);
}

class _EmployeeList extends StatelessWidget {
  final List<EmployeeRow> employees;
  const _EmployeeList({required this.employees});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: employees.length,
      separatorBuilder: (c, i) =>
          Divider(color: Theme.of(context).dividerColor),
      itemBuilder: (context, index) {
        final emp = employees[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                radius: 20,
                child: Text(
                  emp.name.isNotEmpty ? emp.name.substring(0, 1) : "?",
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      emp.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      emp.role,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "\$${emp.profitGenerated.toStringAsFixed(0)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: emp.status == "Activo"
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      emp.status,
                      style: TextStyle(
                        fontSize: 10,
                        color: emp.status == "Activo"
                            ? AppColors.success
                            : AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
