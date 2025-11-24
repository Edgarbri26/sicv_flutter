import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <--- Riverpod
import 'package:sicv_flutter/providers/report_provider.dart';
import 'package:fl_chart/fl_chart.dart';

// Cambiamos a ConsumerWidget para usar Riverpod
class ResumeView extends ConsumerWidget {
  const ResumeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // LEEMOS EL PROVIDER AQUÍ (Riverpod Style)
    final provider = ref.watch(reportProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ya no necesitamos el Consumer<T>, usamos la variable 'provider' directa
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

  // --- LOS WIDGETS AUXILIARES SIGUEN IGUAL ---
  // (Solo asegúrate de pasar 'provider' como parámetro como ya hacíamos)

  Widget _buildHeaderAndFilter(BuildContext context, ReportProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: provider.selectedFilter,
              icon: const Icon(Icons.calendar_today, size: 18),
              items: provider.filterOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (val) => provider.setFilter(val!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiGrid(BuildContext context, ReportProvider provider) {
    final kpis = [
      _KpiData("Ventas Totales", "\$1,250.00", Icons.attach_money, Colors.green, "+12%"),
      _KpiData("Compras", "\$450.00", Icons.shopping_bag_outlined, Colors.blue, "-5%"),
      _KpiData("Ganancia Neta", "\$800.00", Icons.account_balance_wallet_outlined, Colors.purple, "+8%"),
      _KpiData("Alertas Stock", "8 Items", Icons.warning_amber_rounded, Colors.orange, "Urgente"),
    ];

    return LayoutBuilder(builder: (context, constraints) {
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
        itemBuilder: (context, index) => _KpiCard(data: kpis[index]),
      );
    });
  }

  Widget _buildMobileLayout(BuildContext context, ReportProvider provider) {
    return Column(
      children: [
        _ChartContainer(
          title: "Balance Financiero",
          subtitle: "Ventas vs Compras",
          child: _LineChartWidget(provider: provider),
        ),
        const SizedBox(height: 20),
        _ChartContainer(
          title: "Top Productos",
          child: _PieChartWidget(),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, ReportProvider provider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _ChartContainer(
            title: "Balance Financiero",
            height: 450,
            child: _LineChartWidget(provider: provider),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 1,
          child: _ChartContainer(
            title: "Top Productos",
            height: 450,
            child: _PieChartWidget(),
          ),
        ),
      ],
    );
  }
}

// --- WIDGETS DE ESTILO Y GRÁFICOS (Copia el resto del archivo anterior aquí) ---
// (Incluye _ChartContainer, _KpiCard, _LineChartWidget, _PieChartWidget, etc.)
// Asegúrate de que _LineChartWidget reciba 'provider' y use sus datos.

class _ChartContainer extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final double height;

  const _ChartContainer({
    required this.title,
    this.subtitle,
    required this.child,
    this.height = 320,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ],
          const SizedBox(height: 20),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _KpiData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;
  _KpiData(this.title, this.value, this.icon, this.color, this.trend);
}

class _KpiCard extends StatelessWidget {
  final _KpiData data;

  const _KpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), spreadRadius: 1, blurRadius: 5),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
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
                  color: data.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(data.icon, color: data.color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: data.trend.contains("+") ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  data.trend,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: data.trend.contains("+") ? Colors.green : Colors.red,
                  ),
                ),
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                data.title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _LineChartWidget extends StatelessWidget {
  final ReportProvider provider;
  const _LineChartWidget({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.ventasData.isEmpty) {
      return const Center(child: Text("Sin datos disponibles"));
    }
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text("D${value.toInt() + 1}", style: const TextStyle(fontSize: 10)),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: provider.ventasData,
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.15)),
          ),
          LineChartBarData(
            spots: provider.comprasData,
            isCurved: true,
            color: Colors.redAccent,
            barWidth: 3,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

class _PieChartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(value: 40, color: Colors.blueAccent, radius: 50, title: '40%'),
          PieChartSectionData(value: 30, color: Colors.orangeAccent, radius: 50, title: '30%'),
          PieChartSectionData(value: 15, color: Colors.purpleAccent, radius: 50, title: '15%'),
          PieChartSectionData(value: 15, color: Colors.grey[400], radius: 50, title: '15%'),
        ],
      ),
    );
  }
}