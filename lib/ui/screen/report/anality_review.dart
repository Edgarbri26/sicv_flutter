import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

// --- PROVIDER ---
final analyticsProvider = Provider<AnalyticsState>((ref) {
  return AnalyticsState();
});

class AnalyticsState {
  // Simulamos productos: [Nombre, Volumen Vendido (X), Margen Ganancia % (Y), Radio (Importancia)]
  final List<ProductCorrelation> dataPoints = [
    ProductCorrelation("Laptop Gamer", 80, 25, Colors.purple), // Alta venta, Buen margen
    ProductCorrelation("Cable USB", 400, 5, Colors.blue),      // Mucha venta, Poco margen (Volumen)
    ProductCorrelation("Monitor 4K", 20, 45, Colors.orange),   // Poca venta, Alto margen (Nicho)
    ProductCorrelation("Funda Vieja", 10, 2, Colors.grey),     // Poca venta, Poco margen (Descontinuar)
    ProductCorrelation("Mouse", 150, 15, Colors.blueAccent),
    ProductCorrelation("Teclado", 120, 18, Colors.blueAccent),
  ];
}

class ProductCorrelation {
  final String name;
  final double volumeX; // Eje X
  final double marginY; // Eje Y
  final Color color;
  ProductCorrelation(this.name, this.volumeX, this.marginY, this.color);
}

// --- VISTA ---

class AnalyticsReportView extends ConsumerWidget {
  const AnalyticsReportView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(analyticsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             _buildHeader(context),
             const SizedBox(height: 32),
             
             // Tarjeta Grande del Gráfico de Correlación
             Container(
               height: 500,
               padding: const EdgeInsets.all(24),
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(16),
                 boxShadow: [
                   BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                 ]
               ),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   const Text(
                     "Matriz de Rentabilidad",
                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                   ),
                   const Text(
                     "Correlación: Volumen de Venta vs. Margen de Ganancia",
                     style: TextStyle(fontSize: 14, color: Colors.grey),
                   ),
                   const SizedBox(height: 30),
                   Expanded(
                     child: _CorrelationScatterChart(points: data.dataPoints),
                   ),
                   const SizedBox(height: 10),
                   _buildLegend(),
                 ],
               ),
             ),
             const SizedBox(height: 24),
             _buildExplanationCard(),
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
          "Análisis Estratégico",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold, color: const Color(0xFF1F2937)
          ),
        ),
        const Text("Identificación de oportunidades y productos críticos"),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem("Alto Valor", Colors.purple),
        const SizedBox(width: 16),
        _legendItem("Rotación Rápida", Colors.blue),
        const SizedBox(width: 16),
        _legendItem("Nicho / Lujo", Colors.orange),
      ],
    );
  }

  Widget _legendItem(String text, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildExplanationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: const Text(
        "💡 Insight: Los productos en la esquina superior derecha son tus 'Estrellas'. Los de la esquina inferior izquierda (Gris) deberían ser evaluados para liquidación.",
        style: TextStyle(color: Color(0xFF1E40AF), fontSize: 13),
      ),
    );
  }
}

// --- GRÁFICO SCATTER (DISPERSIÓN) ---

class _CorrelationScatterChart extends StatelessWidget {
  final List<ProductCorrelation> points;

  const _CorrelationScatterChart({required this.points});

  @override
  Widget build(BuildContext context) {
    return ScatterChart(
      ScatterChartData(
        scatterSpots: points.map((point) {
          return ScatterSpot(
            point.volumeX,
            point.marginY,
            dotPainter: FlDotCirclePainter(
              color: point.color,
              radius: 8 + (point.volumeX / 50), // El tamaño también indica volumen
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          );
        }).toList(),
        minX: 0,
        maxX: 500, // Ajustar según tus datos reales
        minY: 0,
        maxY: 60,  // Margen máximo esperado
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 10,
          verticalInterval: 50,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.1)),
          getDrawingVerticalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.1)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(color: Colors.grey.withOpacity(0.2)),
            bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          leftTitles: AxisTitles(
            axisNameWidget: const Text("Margen (%)", style: TextStyle(fontSize: 10)),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text("${value.toInt()}%", style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: const Text("Volumen Vendido (Unidades)", style: TextStyle(fontSize: 10)),
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text("${value.toInt()}", style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        // TOOLTIP AL TOCAR UN PUNTO
        scatterTouchData: ScatterTouchData(
          enabled: true,
          touchTooltipData: ScatterTouchTooltipData(
            // tooltipBgColor: Colors.blueGrey, // Deprecated in newer versions
            getTooltipColor: (spot) => Colors.blueGrey, 
            getTooltipItems: (ScatterSpot spot) {
              // Buscar qué producto corresponde a este punto
              // Nota: En producción, mejor pasar el índice en el spot o buscar por X/Y
              final product = points.firstWhere((p) => p.volumeX == spot.x && p.marginY == spot.y);
              return XAxisTooltipItem(
                text: "${product.name}\nVol: ${spot.x.toInt()} | Margen: ${spot.y.toInt()}%",
                textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Clase auxiliar necesaria si usas versiones recientes de fl_chart para el tooltip personalizado
class XAxisTooltipItem extends ScatterTooltipItem {
  XAxisTooltipItem({required String text, required TextStyle textStyle}) 
      : super(
          text, 
          textStyle: textStyle,
          bottomMargin: 10,
        );
}