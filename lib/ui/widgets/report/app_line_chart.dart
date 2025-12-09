import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AppLineChart extends StatelessWidget {
  final List<LineChartBarData> lineChartBarData;
  final List<String> labels;

  const AppLineChart({
    super.key,
    required this.lineChartBarData,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32, // Un poco más de espacio para el texto
              
              // 🔥 1. INTERVALO DINÁMICO
              // Esto es lo que arregla el amontonamiento.
              // Si hay muchos datos, salta números. Si hay pocos, muestra todos.
              interval: _calculateInterval(labels.length),
              
              getTitlesWidget: (value, meta) {
                final index = value.toInt();

                // 🔥 2. VALIDACIÓN DE INDICE
                if (index < 0 || index >= labels.length) {
                  return const SizedBox.shrink();
                }

                // 🔥 3. WIDGET DE TÍTULO
                // Usamos SideTitleWidget para que se alinee mejor con el eje
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    labels[index],
                    style: const TextStyle(
                      fontSize: 10, 
                      fontWeight: FontWeight.bold,
                      color: Colors.grey
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        // Aquí opcionalmente podrías quitar los puntos si son demasiados datos
        // mapeando lineChartBarData para poner dotData: FlDotData(show: false)
        lineBarsData: [...lineChartBarData],
      ),
    );
  }

  // 🔥 4. LÓGICA MATEMÁTICA
  double _calculateInterval(int totalLabels) {
    // Si hay 6 o menos etiquetas, muéstralas todas (intervalo 1)
    if (totalLabels <= 6) return 1.0;

    // Si hay más, divide el total entre 5. 
    // Ej: 30 días / 5 = 6. Mostrará una etiqueta cada 6 días.
    // El resultado siempre será mostrar aprox 5 o 6 etiquetas en pantalla.
    return totalLabels / 5.0;
  }
}