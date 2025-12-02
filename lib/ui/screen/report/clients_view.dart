import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

// Importa los modelos y el provider de tu proyecto
import 'package:sicv_flutter/providers/report/client_report_provider.dart';

// --- WIDGET PRINCIPAL ---

class ClientReportView extends ConsumerWidget {
  const ClientReportView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el estado asíncrono real del provider
    final clientStateAsync = ref.watch(clientReportProvider);
    final currentFilter = ref.watch(clientFilterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: clientStateAsync.when(
        // ESTADO: CARGANDO
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.blue),
        ),
        // ESTADO: ERROR
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error al cargar reporte de clientes:\n$err',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => ref.refresh(clientReportProvider),
                icon: const Icon(Icons.refresh),
                label: const Text("Reintentar"),
              )
            ],
          ),
        ),
        // ESTADO: DATOS LISTOS
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, ref, currentFilter),
              const SizedBox(height: 32),
              // Grid de KPIs
              _buildKpiGrid(context, data),
              const SizedBox(height: 24),
              
              // Layout principal
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
  Widget _buildHeader(BuildContext context, WidgetRef ref, String currentFilter) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Reporte de Clientes",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              "Análisis de fidelización y comportamiento de compra",
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
        // Dropdown de Filtro de Tiempo
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
              icon: const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
              items: const [
                DropdownMenuItem(value: 'week', child: Text("Última Semana")),
                DropdownMenuItem(value: 'month', child: Text("Último Mes")),
                DropdownMenuItem(value: 'year', child: Text("Último Año")),
              ],
              onChanged: (val) {
                if (val != null) {
                  ref.read(clientFilterProvider.notifier).state = val;
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // --- Grid de KPIs (CON DATOS REALES) ---
  Widget _buildKpiGrid(BuildContext context, ClientReportState data) {
    final kpis = [
      _KpiInfo("Total Clientes", "${data.totalClients}", Icons.groups_outlined, Colors.blue),
      _KpiInfo("Ingreso Total", "\$${data.totalRevenue}", Icons.attach_money, Colors.green),
      _KpiInfo("Valor Órden Prom.", "\$${data.avgOrderValue}", Icons.trending_up, Colors.orange),
      _KpiInfo("Cliente Top", data.topClientName, Icons.star_border, Colors.purple),
    ];

    return LayoutBuilder(builder: (context, constraints) {
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
    });
  }

  // --- LAYOUTS ---

  Widget _buildDesktopLayout(BuildContext context, ClientReportState data) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _ChartContainer(
                title: "Top 5 Clientes (Valor Monetario)",
                child: AspectRatio(
                  aspectRatio: 1.7,
                  child: data.topClients.isEmpty 
                    ? const Center(child: Text("Sin data de Top Clientes")) 
                    : _TopClientsChart(data: data.topClients),
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 1,
              child: _ChartContainer(
                title: "Actividad Reciente",
                child: data.clientList.isEmpty
                    ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No hay clientes en el periodo", style: TextStyle(color: Colors.grey))))
                    : _ClientList(clients: data.clientList),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // GRÁFICO DE CORRELACIÓN F-M
        _ChartContainer(
          title: "Matriz Frecuencia vs. Valor (Segmentación)",
          subtitle: "Eje X: N° Órdenes (Frecuencia) | Eje Y: Valor Total (\$)",
          child: SizedBox(
            height: 350,
            child: data.correlationData.isEmpty 
              ? const Center(child: Text("Sin datos de correlación"))
              : _FrequencyValueScatterChart(points: data.correlationData),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, ClientReportState data) {
    return Column(
      children: [
        _ChartContainer(
          title: "Top 5 Clientes",
          child: AspectRatio(
            aspectRatio: 1.3,
            child: data.topClients.isEmpty 
              ? const Center(child: Text("Sin data de Top Clientes")) 
              : _TopClientsChart(data: data.topClients),
          ),
        ),
        const SizedBox(height: 24),
        // GRÁFICO DE CORRELACIÓN EN MÓVIL
        _ChartContainer(
          title: "Matriz Frecuencia vs. Valor",
          subtitle: "Segmentación de clientes",
          child: SizedBox(
            height: 300,
            child: data.correlationData.isEmpty 
              ? const Center(child: Text("Sin datos de correlación"))
              : _FrequencyValueScatterChart(points: data.correlationData),
          ),
        ),
        const SizedBox(height: 24),
        _ChartContainer(
          title: "Actividad Reciente",
          child: data.clientList.isEmpty
            ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No hay clientes en el periodo", style: TextStyle(color: Colors.grey))))
            : _ClientList(clients: data.clientList),
        ),
      ],
    );
  }
}

// ==========================================
// 4. WIDGETS AUXILIARES (Los definidos previamente)
// ==========================================

class _ChartContainer extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  const _ChartContainer({required this.title, required this.child, this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), spreadRadius: 2, blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: info.color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(info.icon, color: info.color, size: 22)), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(info.value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text(info.title, style: TextStyle(fontSize: 12, color: Colors.grey[600]))])]),
    );
  }
}

class _TopClientsChart extends StatelessWidget {
  final List<ClientChartData> data;
  const _TopClientsChart({required this.data});
  @override
  Widget build(BuildContext context) {
    final double maxY = data.isEmpty ? 1 : data.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY, 
        
        // 🚀 MODIFICACIÓN CLAVE: Habilitar y Configurar TouchData
        barTouchData: BarTouchData(
          enabled: true, // Habilitar toque
          touchTooltipData: BarTouchTooltipData(
            // Estilo del tooltip
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final client = data[groupIndex]; // Obtener el objeto de datos del cliente
              
              // Formato para mostrar el Nombre y el Valor Gastado
              return BarTooltipItem(
                '${client.name}\n\$${client.value.toStringAsFixed(2)}', // Contenido del tooltip
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              );
            },
            // Estilo de la burbuja (opcional)
            getTooltipColor: (group) => Colors.blueGrey,
          ),
        ), 
        // -------------------------------------------------------------
        
        titlesData: FlTitlesData(
          // ... (resto de titlesData sin cambios)
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(data[value.toInt()].name.split(" ")[0], style: const TextStyle(fontSize: 10, color: Colors.grey)),
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
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.value,
                color: entry.value.color,
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY, // Ya corregido en el paso anterior
                  color: Colors.grey[100],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ClientList extends StatelessWidget {
  final List<ClientRow> clients;
  const _ClientList({required this.clients});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: clients.length,
      separatorBuilder: (_, __) => const Divider(height: 16),
      itemBuilder: (context, index) {
        final client = clients[index];
        Color statusColor = client.status == "Activo" ? Colors.green : Colors.orange;

        return Row(
          children: [
            CircleAvatar(
              backgroundColor: client.type == "VIP" ? Colors.amber[100] : Colors.blue[50],
              child: Icon(
                client.type == "VIP" ? Icons.star : Icons.person,
                color: client.type == "VIP" ? Colors.amber[800] : Colors.blue,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(client.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(
                    "${client.type} • Status: ${client.status}", // Usamos Status del provider
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("\$${client.totalSpent.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor,
                  ),
                )
              ],
            )
          ],
        );
      },
    );
  }
}

class _FrequencyValueScatterChart extends StatelessWidget {
  final List<ClientCorrelationPoint> points;

  const _FrequencyValueScatterChart({required this.points});

  @override
  Widget build(BuildContext context) {
    double maxX = 0;
    double maxY = 0;
    for (var p in points) {
      if (p.ordersCount > maxX) maxX = p.ordersCount.toDouble();
      if (p.totalSpent > maxY) maxY = p.totalSpent;
    }
    maxX = (maxX == 0 ? 30 : maxX) * 1.2;
    maxY = (maxY == 0 ? 10000 : maxY) * 1.2;

    final double highFrequencyThreshold = maxX * 0.4;
    final double highValueThreshold = maxY * 0.5;

    return ScatterChart(
      ScatterChartData(
        minX: 0, maxX: maxX, minY: 0, maxY: maxY,
        gridData: FlGridData(
          show: true, drawVerticalLine: true, drawHorizontalLine: true,
          getDrawingHorizontalLine: (val) => FlLine(color: val == highValueThreshold ? Colors.green.shade200 : Colors.grey.withOpacity(0.1), strokeWidth: 2),
          getDrawingVerticalLine: (val) => FlLine(color: val == highFrequencyThreshold ? Colors.blue.shade200 : Colors.grey.withOpacity(0.1), strokeWidth: 2),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(axisNameWidget: const Text("N° Órdenes (Frecuencia)", style: TextStyle(fontSize: 10)), sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, meta) => Text("${val.toInt()}", style: const TextStyle(fontSize: 10, color: Colors.grey)))),
          leftTitles: AxisTitles(axisNameWidget: const Text("Valor Total (\$)", style: TextStyle(fontSize: 10)), sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (val, meta) => Text(val >= 1000 ? "${(val/1000).toStringAsFixed(0)}k" : "${val.toInt()}", style: const TextStyle(fontSize: 10, color: Colors.grey)))),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.withOpacity(0.2))),
        scatterSpots: points.map((point) {
          bool highFreq = point.ordersCount >= highFrequencyThreshold;
          bool highValue = point.totalSpent >= highValueThreshold;
          
          Color color;
          double radius = 6;

          if (highFreq && highValue) { color = Colors.purple; radius = 10; } 
          else if (highFreq && !highValue) { color = Colors.orange; } 
          else if (!highFreq && highValue) { color = Colors.teal; } 
          else { color = Colors.red; }

          return ScatterSpot(point.ordersCount.toDouble(), point.totalSpent, dotPainter: FlDotCirclePainter(color: color, radius: radius, strokeWidth: 0));
        }).toList(),
        scatterTouchData: ScatterTouchData(
          enabled: true,
          touchTooltipData: ScatterTouchTooltipData(
            getTooltipColor: (_) => Colors.blueGrey,
            getTooltipItems: (ScatterSpot spot) {
              try {
                final match = points.firstWhere((p) => p.ordersCount.toDouble() == spot.x && p.totalSpent == spot.y);
                return XAxisTooltipItem(text: "${match.name}\nÓrdenes: ${match.ordersCount}\nValor: \$${match.totalSpent.toStringAsFixed(0)}", textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12));
              } catch (e) { return null; }
            },
          ),
        ),
      ),
    );
  }
}

class XAxisTooltipItem extends ScatterTooltipItem {

  XAxisTooltipItem({required String text, required TextStyle textStyle}) : super(text, textStyle: textStyle, bottomMargin: 10);
}