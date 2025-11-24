/*// lib/views/inventario_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sicv_flutter/providers/report_provider.dart';

class InventoryView extends StatelessWidget {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) { // <-- 'context' se define aquí
    return Consumer<ReportProvider>(
      builder: (context, provider, child) { // <-- 'context' se redefine aquí (está bien)
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Este no necesita 'context', así que está bien
              _buildKpiSection(provider),
              const SizedBox(height: 24),

              LayoutBuilder(
                builder: (context, constraints) { // <-- Este 'context' es el que usaremos
                  bool isDesktop = constraints.maxWidth > 800;
                  if (isDesktop) {
                    // Pasamos 'context' a los métodos
                    return _buildDesktopLayout(context, provider); // <-- CAMBIO
                  } else {
                    return _buildMobileLayout(context, provider); // <-- CAMBIO
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKpiSection(ReportProvider provider) {
    return Wrap(
      spacing: 16.0,
      runSpacing: 16.0,
      children: [
        _KpiCard(
          title: 'Valor Total del Inventario',
          
          // --- LA SOLUCIÓN ---
          // Usa (provider.totalInventoryValue ?? 0) para decir "si es nulo, usa 0"
          value: '\$${(provider.totalInventoryValue).toStringAsFixed(2)}',
          // --- FIN DE LA SOLUCIÓN ---

          icon: Icons.attach_money,
          color: Colors.blue,
        ),
        _KpiCard(
          title: 'Items Agotados (Stock 0)',
          // También aquí por seguridad
          value: (provider.itemsOutOfStock).toString(),
          icon: Icons.error_outline,
          color: Colors.red,
        ),
        _KpiCard(
          title: 'Items con Bajo Stock',
          // Y aquí
          value: (provider.itemsLowStock).toString(),
          icon: Icons.warning_amber_outlined,
          color: Colors.orange,
        ),
      ],
    );
  }

  /// Layout para PC (recibe 'context')
  Widget _buildDesktopLayout(BuildContext context, ReportProvider provider) { // <-- CAMBIO
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildBarChartCard(context, provider), // <-- CAMBIO (pasamos context)
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: _buildPieChartCard(context, provider), // <-- CAMBIO (pasamos context)
        ),
      ],
    );
  }

  /// Layout para Móvil (recibe 'context')
  Widget _buildMobileLayout(BuildContext context, ReportProvider provider) { // <-- CAMBIO
    return Column(
      children: [
        _buildBarChartCard(context, provider), // <-- CAMBIO (pasamos context)
        const SizedBox(height: 16),
        _buildPieChartCard(context, provider), // <-- CAMBIO (pasamos context)
      ],
    );
  }

  /// Construye la tarjeta para el Gráfico de Barras (recibe 'context')
  Widget _buildBarChartCard(BuildContext context, ReportProvider provider) { // <-- CAMBIO
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productos con Bajo Stock',
              style: Theme.of(context).textTheme.titleLarge, // <-- Ahora funciona
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  // ... (resto del código del gráfico de barras se queda igual) ...
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: provider.lowStockBarData,
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 38,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= provider.lowStockProductNames.length) {
                            return const Text('');
                          }
                          return SideTitleWidget(
                            space: 4.0,
                            meta: meta, // <-- ¡ESTA ES LA LÍNEA QUE FALTABA!
                            child: Text(
                              provider.lowStockProductNames[index],
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey[200],
                      strokeWidth: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la tarjeta para el Gráfico de Pastel (recibe 'context')
  Widget _buildPieChartCard(BuildContext context, ReportProvider provider) { // <-- CAMBIO
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Valor por Categoría',
              style: Theme.of(context).textTheme.titleLarge, // <-- Ahora funciona
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: provider.categorySections,
                  centerSpaceRadius: 60,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const Center(
              child: Text(
                '(Aquí iría la leyenda: Azul=Laptops, Verde=Teléfonos...)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// La clase _KpiCard se queda igual, ya es un StatelessWidget y maneja su propio context
class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 280),
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                // ignore: deprecated_member_use
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/