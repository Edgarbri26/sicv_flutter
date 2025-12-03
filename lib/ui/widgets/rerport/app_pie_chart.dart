import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sicv_flutter/providers/report/inventory_provider.dart';

class AppPieChart extends StatefulWidget {
  final List<AppPieChartData> data;
  // NOTA DE ARQUITECTURA: Eliminamos 'radius' del constructor.
  // El componente ahora es lo suficientemente inteligente para calcular su propio tamaño.

  const AppPieChart({super.key, required this.data});

  @override
  State<AppPieChart> createState() => _AppPieChartState();
}

class _AppPieChartState extends State<AppPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder: Nos da las restricciones exactas del padre en tiempo real.
    return LayoutBuilder(
      builder: (context, constraints) {
        // 1. Encontrar la dimensión limitante (ancho o alto)
        final double minDimension = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;

        // Evitamos errores de renderizado si el espacio es nulo o muy pequeño
        if (minDimension <= 0) return const SizedBox.shrink();

        // 2. Definir proporciones relativas (Google Material Design specs)
        // El radio será el 40% del espacio disponible (dejando 10% para márgenes/animaciones)
        final double responsiveRadius = minDimension * 0.4;

        // El hueco central (donut) será el 15% del espacio
        final double centerSpaceRadius = minDimension * 0.15;

        // La fuente base será el 4% del tamaño total
        final double baseFontSize = minDimension * 0.04;

        return PieChart(
          PieChartData(
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                setState(() {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    touchedIndex = -1;
                    return;
                  }
                  touchedIndex =
                      pieTouchResponse.touchedSection!.touchedSectionIndex;
                });
              },
            ),
            sectionsSpace: 2,
            centerSpaceRadius: centerSpaceRadius, // Usamos el valor dinámico
            // Pasamos los cálculos geométricos a la función constructora
            sections: _buildPieChartSections(responsiveRadius, baseFontSize),
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    double baseRadius,
    double baseFontSize,
  ) {
    return List.generate(widget.data.length, (i) {
      final data = widget.data[i];
      final isTouched = i == touchedIndex;

      // Animación de Hover: Escalamos relativo al tamaño base calculado
      final double fontSize = isTouched ? baseFontSize * 1.4 : baseFontSize;
      final double currentRadius = isTouched
          ? baseRadius *
                1.15 // Crece un 15% al tocar
          : baseRadius;

      return PieChartSectionData(
        color: data.color,
        value: data.value,
        title: '${data.value.toStringAsFixed(1)}%',
        radius: currentRadius,

        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black26, blurRadius: 2)],
        ),

        // Lógica del Tooltip mantenida y optimizada
        badgeWidget: isTouched ? _buildTooltip(data) : null,

        // Posicionamiento dinámico del tooltip
        badgePositionPercentageOffset: 1.3,
      );
    });
  }

  Widget _buildTooltip(AppPieChartData data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color:
            Colors.blueGrey.shade900, // Un tono más "profesional" que black87
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data.name,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '${data.value.toStringAsFixed(1)}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14, // Hacemos el número el protagonista
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
