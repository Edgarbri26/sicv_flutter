import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

// --- PROVIDER SIMULADO ---
final clientReportProvider = Provider<ClientReportState>((ref) {
  return ClientReportState();
});

class ClientReportState {
  final int totalClients = 450;
  final int newClients = 28;
  final String activeRate = "85%";
  final String topRegion = "Lara";

  // Top 5 Clientes para Gráfico de Barras
  final List<ClientChartData> topClients = [
    ClientChartData("Distribuidora A", 15000, Colors.blue),
    ClientChartData("Tech Solutions", 12500, Colors.blueAccent),
    ClientChartData("Inversiones J", 9800, Colors.lightBlue),
    ClientChartData("Muebles Lara", 7500, Colors.cyan),
    ClientChartData("Particular", 4200, Colors.teal),
  ];

  // Lista detallada
  final List<ClientRow> clientList = [
    ClientRow("Distribuidora Alpha", "VIP", 15000, "Hace 2 días", true),
    ClientRow("Tech Solutions CA", "Frecuente", 12500, "Hace 5 días", true),
    ClientRow("Carlos Mendez", "Nuevo", 250, "Ayer", true),
    ClientRow("Inversiones J&J", "Regular", 9800, "Hace 25 días", false),
    ClientRow("Bodega Central", "Regular", 1200, "Hace 3 días", true),
  ];

  // <--- NUEVO: DATOS PARA LA MATRIZ DE RIESGO
  // (Nombre, Días sin comprar, Total Gastado Histórico)
  final List<ClientRetentionPoint> retentionList = [
    ClientRetentionPoint("Cliente A", 10, 5000),   // Reciente, Buen valor
    ClientRetentionPoint("Cliente B", 90, 12000),  // ALERTA: Mucho valor, hace mucho no viene
    ClientRetentionPoint("Cliente C", 5, 500),     // Nuevo, poco valor
    ClientRetentionPoint("Cliente D", 65, 8000),   // ALERTA
    ClientRetentionPoint("Cliente E", 30, 2000),   // Promedio
    ClientRetentionPoint("Cliente F", 80, 100),    // Perdido, pero bajo valor (menos grave)
    ClientRetentionPoint("Cliente G", 15, 7000),
  ];
}

class ClientChartData {
  final String name;
  final double value;
  final Color color;
  ClientChartData(this.name, this.value, this.color);
}

class ClientRow {
  final String name;
  final String type;
  final double totalSpent;
  final String lastPurchase;
  final bool isActive;
  ClientRow(this.name, this.type, this.totalSpent, this.lastPurchase, this.isActive);
}

// <--- NUEVO: CLASE PARA PUNTOS DE DISPERSIÓN
class ClientRetentionPoint {
  final String name;
  final double daysSinceLast;
  final double totalValue;
  ClientRetentionPoint(this.name, this.daysSinceLast, this.totalValue);
}

// --- VISTA PRINCIPAL ---

class ClientReportView extends ConsumerWidget {
  const ClientReportView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(clientReportProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
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
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
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
    );
  }

  Widget _buildKpiGrid(BuildContext context, ClientReportState data) {
    final kpis = [
      _KpiInfo("Total Clientes", "${data.totalClients}", Icons.groups_outlined, Colors.blue),
      _KpiInfo("Nuevos (Mes)", "+${data.newClients}", Icons.person_add_alt, Colors.green),
      _KpiInfo("Tasa Actividad", data.activeRate, Icons.trending_up, Colors.orange),
      _KpiInfo("Región Top", data.topRegion, Icons.map_outlined, Colors.purple),
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

  Widget _buildDesktopLayout(BuildContext context, ClientReportState data) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _ChartContainer(
                title: "Top 5 Clientes (Ventas)",
                child: AspectRatio(
                  aspectRatio: 1.7,
                  child: _TopClientsChart(data: data.topClients),
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 1,
              child: _ChartContainer(
                title: "Actividad Reciente",
                child: _ClientList(clients: data.clientList),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // <--- NUEVO: GRÁFICO DE DISPERSIÓN (ANCHO COMPLETO EN DESKTOP)
        _ChartContainer(
          title: "Matriz de Riesgo y Retención",
          subtitle: "Clientes en Zona Roja: Alto Valor + Inactividad prolongada (>60 días)",
          child: SizedBox(
            height: 350,
            child: _RetentionScatterChart(points: data.retentionList),
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
            child: _TopClientsChart(data: data.topClients),
          ),
        ),
        const SizedBox(height: 24),
        // <--- NUEVO: GRÁFICO DE DISPERSIÓN EN MÓVIL
        _ChartContainer(
          title: "Matriz de Riesgo",
          subtitle: "Días inactivo vs. Valor (\$)",
          child: SizedBox(
            height: 300,
            child: _RetentionScatterChart(points: data.retentionList),
          ),
        ),
        const SizedBox(height: 24),
        _ChartContainer(
          title: "Actividad Reciente",
          child: _ClientList(clients: data.clientList),
        ),
      ],
    );
  }
}

// --- WIDGETS AUXILIARES ---

class _ChartContainer extends StatelessWidget {
  final String title;
  final String? subtitle; // <--- Opcional para explicar la gráfica compleja
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
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
          ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: info.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(info.icon, color: info.color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(info.value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(info.title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          )
        ],
      ),
    );
  }
}

// --- GRÁFICOS Y LISTA ---

class _TopClientsChart extends StatelessWidget {
  final List<ClientChartData> data;
  const _TopClientsChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 20000,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      data[value.toInt()].name.split(" ")[0], // Solo primera palabra
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
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
                  toY: 20000,
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

// <--- NUEVO: WIDGET DE GRÁFICO DE DISPERSIÓN INTEGRADO
class _RetentionScatterChart extends StatelessWidget {
  final List<ClientRetentionPoint> points;

  const _RetentionScatterChart({required this.points});

  @override
  Widget build(BuildContext context) {
    return ScatterChart(
      ScatterChartData(
        minX: 0, 
        maxX: 100, // Ajustar a max días de inactividad
        minY: 0, 
        maxY: 15000, // Ajustar a max ventas

        // Nota: RangeAnnotations no está disponible en ScatterChartData en esta versión de fl_chart.
        // Si desea resaltar zonas de riesgo, puede dibujar un contenedor superpuesto detrás del gráfico usando un Stack.

        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 5000,
          verticalInterval: 20,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.1)),
          getDrawingVerticalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.1)),
        ),
        
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            axisNameWidget: const Text("Días sin comprar", style: TextStyle(fontSize: 10)),
            sideTitles: SideTitles(
              showTitles: true, 
              reservedSize: 30,
              getTitlesWidget: (val, meta) => Text("${val.toInt()}d", style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: const Text("Valor Total (\$)", style: TextStyle(fontSize: 10)),
            sideTitles: SideTitles(
              showTitles: true, 
              reservedSize: 40,
              getTitlesWidget: (val, meta) => Text("${(val/1000).toStringAsFixed(0)}k", style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),

        // Lógica de los puntos
        scatterSpots: points.map((point) {
          // Lógica de negocio: Si lleva más de 60 días inactivo Y ha gastado más de $5000
          // Es un cliente VIP en riesgo de fuga (Punto ROJO y GRANDE)
          bool isAtRisk = point.daysSinceLast > 60 && point.totalValue > 5000;
          
          return ScatterSpot(
            point.daysSinceLast,
            point.totalValue,
            dotPainter: FlDotCirclePainter(
              color: isAtRisk ? Colors.redAccent : Colors.blue.withOpacity(0.5),
              radius: isAtRisk ? 10 : 6, // Más grandes si son importantes
              strokeWidth: isAtRisk ? 2 : 0,
              strokeColor: Colors.white,
            ),
          );
        }).toList(),

        // Tooltip al tocar el punto
        scatterTouchData: ScatterTouchData(
          enabled: true,
          touchTooltipData: ScatterTouchTooltipData(
            getTooltipColor: (_) => Colors.blueGrey,
            getTooltipItems: (ScatterSpot spot) {
               // Buscamos el cliente que corresponde a este punto
               // (En producción usarías un ID, aquí buscamos por coincidencia)
               final match = points.firstWhere((p) => p.daysSinceLast == spot.x && p.totalValue == spot.y, orElse: () => ClientRetentionPoint("?", 0,0));
               
               return XAxisTooltipItem(
                 text: "${match.name}\n${spot.x.toInt()} días inactivo",
                 textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
               );
            },
          ),
        ),
      ),
    );
  }
}

// Necesario para el Tooltip personalizado en ScatterChart
class XAxisTooltipItem extends ScatterTooltipItem {
  XAxisTooltipItem({required String text, required TextStyle textStyle}) 
      : super(text, textStyle: textStyle, bottomMargin: 10);
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
                    "${client.type} • Última compra: ${client.lastPurchase}",
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
                    color: client.isActive ? Colors.green : Colors.grey[300],
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