// lib/views/clientes_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sicv_flutter/providers/report_provider.dart';

/// ClientesView
///
/// Muestra KPIs y gráficos sobre la cartera de clientes.
/// Es responsiva: 2 columnas en PC y 1 en móvil.
class ClientsView extends StatelessWidget {
  const ClientsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. SECCIÓN DE KPIs ---
              _buildKpiSection(provider),
              const SizedBox(height: 24),

              // --- 2. SECCIÓN RESPONSIVA DE GRÁFICOS ---
              LayoutBuilder(
                builder: (context, constraints) {
                  bool isDesktop = constraints.maxWidth > 800;
                  if (isDesktop) {
                    return _buildDesktopLayout(context, provider);
                  } else {
                    return _buildMobileLayout(context, provider);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Construye la sección de tarjetas de KPIs.
  Widget _buildKpiSection(ReportProvider provider) {
    return Wrap(
      spacing: 16.0,
      runSpacing: 16.0,
      children: [
        _KpiCard(
          title: 'Cuentas por Cobrar',
          value: '\$${(provider.cuentasPorCobrar).toStringAsFixed(2)}',
          icon: Icons.receipt_long_outlined,
          color: Colors.orange,
        ),
        _KpiCard(
          title: 'Clientes Nuevos (Este Mes)',
          value: (provider.clientesNuevosEsteMes).toString(),
          icon: Icons.person_add_alt_1_outlined,
          color: Colors.teal,
        ),
      ],
    );
  }

  /// Layout para PC (2 columnas)
  Widget _buildDesktopLayout(BuildContext context, ReportProvider provider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2, // 2/3 del espacio
          child: _buildBarChartCard(context, provider),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1, // 1/3 del espacio
          child: _buildPieChartCard(context, provider),
        ),
      ],
    );
  }

  /// Layout para Móvil (1 columna)
  Widget _buildMobileLayout(BuildContext context, ReportProvider provider) {
    return Column(
      children: [
        _buildBarChartCard(context, provider),
        const SizedBox(height: 16),
        _buildPieChartCard(context, provider),
      ],
    );
  }

  /// Construye la tarjeta para el Gráfico de Barras (Top Clientes)
  Widget _buildBarChartCard(BuildContext context, ReportProvider provider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top 5 Clientes (por Venta)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              // El widget BarChart recibe los datos y la orientación
              child: BarChart(
                BarChartData(
                  // Rota el gráfico 90 grados (1 cuarto de vuelta)
                  rotationQuarterTurns: 1,
                  barGroups: provider.topCustomerBarData,
                  // Títulos (Ejes)
                  titlesData: FlTitlesData(
                    show: true,
                    // Eje Y (Izquierda) - Los Nombres
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 100, // Espacio para nombres largos
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= provider.topCustomerNames.length) {
                            return const Text('');
                          }
                          return Text(
                            provider.topCustomerNames[index],
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.right,
                          );
                        },
                      ),
                    ),
                    // Eje X (Abajo) - Los Valores
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          if (value % 500 == 0) {
                            return Text('\$${value.toInt()}');
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: false,
                    verticalInterval: 500,
                    getDrawingVerticalLine: (value) => FlLine(
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

  /// Construye la tarjeta para el Gráfico de Pastel (Nuevos vs. Recurrentes)
  Widget _buildPieChartCard(BuildContext context, ReportProvider provider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Clientes Nuevos vs. Recurrentes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: provider.customerPieData,
                  centerSpaceRadius: 60,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Leyenda del Gráfico
            const Column(
              children: [
                _Indicator(
                  color: Color(0xFF5C6BC0), // Colors.indigo[400]
                  text: 'Clientes Recurrentes',
                  isSquare: false,
                ),
                SizedBox(height: 4),
                _Indicator(
                  color: Color(0xFF4DB6AC), // Colors.teal[300]
                  text: 'Clientes Nuevos',
                  isSquare: false,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

/// Widget privado para la leyenda del gráfico de pastel
class _Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;

  const _Indicator({
    required this.color,
    required this.text,
    this.isSquare = false,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Text(text)
      ],
    );
  }
}

/// Widget privado para mostrar una tarjeta de KPI individual.
/// (Copiado de ResumenView)
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
}