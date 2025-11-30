import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

// --- 1. MOCK PROVIDER (Simulación de datos para la vista) ---
// En tu app real, esto vendría de tu backend/firebase
final employeeReportProvider = Provider<EmployeeReportState>((ref) {
  return EmployeeReportState();
});

class EmployeeReportState {
  final String totalCommissions = "1,250.00";
  final int activeEmployees = 12;
  final String topPerformer = "Ana G.";
  final double avgSales = 4500.00;
  
  // Datos simulados para el gráfico de barras (Ventas por empleado)
  final List<EmployeeChartData> chartData = [
    EmployeeChartData("Juan", 8, Colors.blueAccent),
    EmployeeChartData("Ana", 12, Colors.purpleAccent),
    EmployeeChartData("Luis", 6, Colors.orangeAccent),
    EmployeeChartData("Sofía", 10, Colors.green),
    EmployeeChartData("Pedro", 7, Colors.blueGrey),
  ];

  // Datos para la lista de empleados
  final List<EmployeeRow> employees = [
    EmployeeRow("Ana García", "Vendedora", 12500, "Activo", "assets/avatar1.png"),
    EmployeeRow("Sofía Lopez", "Gerente", 10200, "Activo", "assets/avatar2.png"),
    EmployeeRow("Juan Perez", "Cajero", 8100, "Vacaciones", "assets/avatar3.png"),
    EmployeeRow("Pedro Ruiz", "Almacén", 7400, "Activo", "assets/avatar4.png"),
  ];
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
  final double sales;
  final String status;
  final String avatarUrl; // Usaremos iconos por defecto si no hay imagen
  EmployeeRow(this.name, this.role, this.sales, this.status, this.avatarUrl);
}

// --- 2. VISTA PRINCIPAL ---

class EmployeeReportView extends ConsumerWidget {
  const EmployeeReportView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(employeeReportProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Fondo gris muy suave profesional
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            
            // Sección de KPIs (Tarjetas superiores)
            _buildKpiGrid(context, data),
            const SizedBox(height: 24),

            // Layout Adaptativo (Gráfico + Lista)
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

  // --- Header y Filtros ---
  Widget _buildHeader(BuildContext context) {
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
        // Filtro de Fecha
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            children: const [
              Icon(Icons.calendar_month_outlined, size: 16, color: Colors.grey),
              SizedBox(width: 8),
              Text("Este Mes", style: TextStyle(fontWeight: FontWeight.w600)),
              Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }

  // --- Grid de KPIs ---
  Widget _buildKpiGrid(BuildContext context, EmployeeReportState data) {
    // Definimos los datos de las tarjetas
    final kpis = [
      _KpiInfo("Empleados Activos", "${data.activeEmployees}", Icons.people_alt_outlined, Colors.blue),
      _KpiInfo("Mejor Desempeño", data.topPerformer, Icons.star_border, Colors.amber),
      _KpiInfo("Comisiones Totales", "\$${data.totalCommissions}", Icons.attach_money, Colors.green),
      _KpiInfo("Promedio Ventas", "\$${data.avgSales.toStringAsFixed(0)}", Icons.bar_chart, Colors.purple),
    ];

    return LayoutBuilder(builder: (context, constraints) {
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
    });
  }

  // --- Layouts Responsivos ---

  Widget _buildDesktopLayout(BuildContext context, EmployeeReportState data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna Izquierda: Gráfico Principal
        Expanded(
          flex: 2,
          child: _ChartContainer(
            title: "Rendimiento de Ventas",
            subtitle: "Comparativa por empleado (Miles \$)",
            child: AspectRatio(
              aspectRatio: 1.8,
              child: _EmployeeBarChart(data: data.chartData),
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Columna Derecha: Lista de Empleados
        Expanded(
          flex: 1,
          child: _ChartContainer(
            title: "Detalle de Equipo",
            subtitle: "Estado y ventas acumuladas",
            child: _EmployeeList(employees: data.employees),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, EmployeeReportState data) {
    return Column(
      children: [
        _ChartContainer(
          title: "Rendimiento de Ventas",
          subtitle: "Comparativa por empleado",
          child: AspectRatio(
            aspectRatio: 1.5,
            child: _EmployeeBarChart(data: data.chartData),
          ),
        ),
        const SizedBox(height: 24),
        _ChartContainer(
          title: "Detalle de Equipo",
          subtitle: "Estado actual",
          child: _EmployeeList(employees: data.employees),
        ),
      ],
    );
  }
}

// --- 3. WIDGETS AUXILIARES (Estética Profesional) ---

// Contenedor Blanco estilo "Card"
class _ChartContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _ChartContainer({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

// Tarjeta KPI Simple
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: info.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(info.icon, color: info.color, size: 20),
              ),
              // Podrías poner un porcentaje aquí si quisieras
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                info.value,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              Text(
                info.title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          )
        ],
      ),
    );
  }
}

// --- 4. GRÁFICOS (FL_CHART IMPLEMENTATION) ---

class _EmployeeBarChart extends StatelessWidget {
  final List<EmployeeChartData> data;

  const _EmployeeBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 15, // Ajusta según tus datos reales
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            // getTooltipColor: (group) => Colors.blueGrey, // Uncomment for newer versions
            getTooltipColor: (group) => Colors.blueGrey, // Deprecated in newer fl_chart, use getTooltipColor
            tooltipBorderRadius: BorderRadius.circular(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.round()}k',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      data[value.toInt()].name,
                      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.1),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: item.value,
                color: item.color,
                width: 24, // Ancho de la barra
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: 15, // Max Y
                  color: Colors.grey.withOpacity(0.05),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// --- 5. LISTA DE EMPLEADOS (Estilo Tabla/Lista) ---

class _EmployeeList extends StatelessWidget {
  final List<EmployeeRow> employees;

  const _EmployeeList({required this.employees});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: employees.length,
      separatorBuilder: (c, i) => Divider(color: Colors.grey.withOpacity(0.1)),
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
                  emp.name.substring(0, 1),
                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(emp.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(emp.role, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("\$${emp.sales.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: emp.status == "Activo" ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      emp.status,
                      style: TextStyle(
                        fontSize: 10,
                        color: emp.status == "Activo" ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }
}