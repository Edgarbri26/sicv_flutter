import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

// 1. IMPORTA TU PROVIDER (Donde están definidos los modelos y el estado)
// Ajusta la ruta si tu archivo se llama diferente
import 'package:sicv_flutter/providers/report/employee_provider.dart';

class EmployeeReportView extends ConsumerWidget {
  const EmployeeReportView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el estado del provider asíncrono
    final employeeStateAsync = ref.watch(employeeReportProvider);
    // Si usas el filtro en el header, descomenta esto:
    final currentFilter = ref.watch(employeeFilterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: employeeStateAsync.when(
        // ESTADO: CARGANDO
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.blue)),
        // ESTADO: ERROR
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error al cargar reporte de personal:\n$err',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
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
              // Header con filtro
              _buildHeader(context, ref, currentFilter),
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

  // --- Header y Filtros ---
  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    String currentFilter,
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
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Desempeño, comisiones y actividad reciente",
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
        // Filtro Dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentFilter,
              icon: const Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.grey,
              ),
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              items: const [
                DropdownMenuItem(value: 'week', child: Text("Última Semana")),
                DropdownMenuItem(value: 'month', child: Text("Último Mes")),
                DropdownMenuItem(value: 'year', child: Text("Último Año")),
              ],
              onChanged: (val) {
                if (val != null) {
                  ref.read(employeeFilterProvider.notifier).state = val;
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiGrid(BuildContext context, EmployeeReportState data) {
    final kpis = [
      _KpiInfo(
        "Empleados Activos",
        "${data.activeEmployees}",
        Icons.people_alt_outlined,
        Colors.blue,
      ),
      _KpiInfo(
        "Mejor Desempeño",
        data.topPerformer,
        Icons.star_border,
        Colors.amber,
      ),
      _KpiInfo(
        "Ganancia Total",
        "\$${data.totalProfit}",
        Icons.attach_money,
        Colors.green,
      ),
      _KpiInfo(
        "Promedio Ganancia",
        "\$${data.avgProfit}",
        Icons.bar_chart,
        Colors.purple,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
        double ratio = constraints.maxWidth < 600 ? 1.5 : 2.2;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: ratio,
          ),
          itemCount: kpis.length,
          itemBuilder: (context, index) => _KpiCard(info: kpis[index]),
        );
      },
    );
  }

  // --- LAYOUTS ---

  Widget _buildDesktopLayout(BuildContext context, EmployeeReportState data) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gráfico de Barras
            Expanded(
              flex: 1,
              child: _ChartContainer(
                title: "Ventas por Empleado",
                subtitle: "Cantidad de ventas realizadas",
                child: AspectRatio(
                  aspectRatio: 1.6,
                  child: data.chartData.isEmpty
                      ? const Center(
                          child: Text(
                            "Sin datos de ventas",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : _EmployeeBarChart(data: data.chartData),
                ),
              ),
            ),
            const SizedBox(width: 24),
            // Gráfico de Correlación
            Expanded(
              flex: 1,
              child: _ChartContainer(
                title: "Análisis de Desempeño: Cantidad vs Ganancia",
                // Subtítulo más limpio o vacío, ya que usaremos la guía visual
                subtitle: "Relación entre el esfuerzo de venta y el retorno financiero",
                child: Column(
                  children: [
                    // --- GUÍA DE INTERPRETACIÓN (NUEVA LEYENDA) ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Explicación Eje Vertical
                          _buildGuideItem(
                            Icons.attach_money, 
                            Colors.green, 
                            "Eje Vertical", 
                            "Rentabilidad Total"
                          ),
                          // Explicación Eje Horizontal
                          _buildGuideItem(
                            Icons.shopping_cart, 
                            Colors.blue, 
                            "Eje Horizontal", 
                            "Volumen de Ventas"
                          ),
                          // Explicación de la Meta (Dónde mirar)
                          _buildGuideItem(
                            Icons.trending_up, 
                            Colors.orange, 
                            "Objetivo", 
                            "Zona Superior Derecha"
                          ),
                        ],
                      ),
                    ),
                    // ----------------------------------------------

                    AspectRatio(
                      aspectRatio: 1.6,
                      child: data.correlationData.isEmpty
                          ? const Center(
                              child: Text(
                                "Sin datos de correlación",
                                style: TextStyle(color: Colors.grey),
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
        const SizedBox(height: 24),
        // Lista de Empleados
        _ChartContainer(
          title: "Detalle de Equipo",
          subtitle: "Estado y ganancias generadas",
          child: data.employees.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "No hay empleados con ventas",
                      style: TextStyle(color: Colors.grey),
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
        _ChartContainer(
          title: "Correlación: Cantidad vs Ganancia",
          subtitle: "Rendimiento individual",
          child: AspectRatio(
            aspectRatio: 1.3,
            child: data.correlationData.isEmpty
                ? const Center(
                    child: Text(
                      "Sin datos",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : _CorrelationChart(data: data.correlationData),
          ),
        ),
        const SizedBox(height: 24),
        _ChartContainer(
          title: "Ventas por Empleado",
          subtitle: "Cantidad total",
          child: AspectRatio(
            aspectRatio: 1.5,
            child: data.chartData.isEmpty
                ? const Center(
                    child: Text(
                      "Sin datos",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : _EmployeeBarChart(data: data.chartData),
          ),
        ),
        const SizedBox(height: 24),
        _ChartContainer(
          title: "Detalle de Equipo",
          subtitle: "Estado actual",
          child: data.employees.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "No hay empleados con ventas",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              : _EmployeeList(employees: data.employees),
        ),
      ],
    );
  }
}

// --- 4. WIDGETS AUXILIARES ---

class _ChartContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const _ChartContainer({
    required this.title,
    required this.subtitle,
    required this.child,
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
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: info.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(info.icon, color: info.color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                info.value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                info.title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmployeeBarChart extends StatelessWidget {
  final List<EmployeeChartData> data;
  const _EmployeeBarChart({required this.data});
  @override
  Widget build(BuildContext context) {
    // Calculamos el máximo dinámico para el eje Y
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
            getTooltipColor: (group) => Colors.blueGrey,
            tooltipBorderRadius: BorderRadius.circular(8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                BarTooltipItem(
                  rod.toY.toInt().toString(),
                  const TextStyle(
                    color: Colors.white,
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
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 5,
          getDrawingHorizontalLine: (val) =>
              FlLine(color: Colors.grey.withValues(alpha: 0.1), strokeWidth: 1),
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
          color: Colors.grey, 
          fontWeight: FontWeight.w500
        ),
      ),
      Text(
        value,
        style: const TextStyle(
          fontSize: 11, 
          fontWeight: FontWeight.bold
        ),
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
              FlLine(color: Colors.grey.withValues(alpha: 0.1)),
          getDrawingVerticalLine: (val) =>
              FlLine(color: Colors.grey.withValues(alpha: 0.1)),
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
                style: const TextStyle(fontSize: 10, color: Colors.grey),
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
                style: const TextStyle(fontSize: 10, color: Colors.grey),
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
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
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
            getTooltipColor: (spot) => Colors.blueGrey,
            getTooltipItems: (ScatterSpot spot) {
              try {
                // Buscamos el punto más cercano para mostrar el tooltip
                final employee = data.firstWhere(
                  (e) =>
                      (e.salesCount - spot.x).abs() < 0.1 &&
                      (e.totalProfit - spot.y).abs() < 0.1,
                  orElse: () => EmployeePerformancePoint(
                    "Desconocido",
                    0,
                    0,
                    Colors.grey,
                  ),
                );
                return XAxisTooltipItem(
                  text:
                      "${employee.name}\nVentas: ${spot.x.toInt()}\nGanancia: \$${spot.y.toStringAsFixed(0)}",
                  textStyle: const TextStyle(
                    color: Colors.white,
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
          Divider(color: Colors.grey.withValues(alpha: 0.1)),
      itemBuilder: (context, index) {
        final emp = employees[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.shade50,
                radius: 20,
                child: Text(
                  emp.name.length > 0 ? emp.name.substring(0, 1) : "?",
                  style: const TextStyle(
                    color: Colors.blue,
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
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // FIX: Usamos profitGenerated, que es el valor real que viene del backend
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
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      emp.status,
                      style: TextStyle(
                        fontSize: 10,
                        color: emp.status == "Activo"
                            ? Colors.green
                            : Colors.orange,
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
