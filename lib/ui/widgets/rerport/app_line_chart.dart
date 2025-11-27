import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AppLineChartWidget extends StatelessWidget {
  final List<LineChartBarData> lineChartData;
  const AppLineChartWidget({super.key, required this.lineChartData});

  @override
  Widget build(BuildContext context) {
    if (lineChartData.isEmpty) {
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
                child: Text(
                  "D${value.toInt() + 1}",
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: lineChartData,
      ),
    );
  }
}
