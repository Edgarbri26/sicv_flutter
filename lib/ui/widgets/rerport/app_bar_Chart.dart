import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AppBarChart extends StatelessWidget {
  final List<BarChartGroupData> barChartData;
  final List<String> labels;

  const AppBarChart({
    super.key,
    required this.barChartData,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: barChartData,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(labels[value.toInt()]);
              },
            ),
          ),
        ),
      ),

      duration: Duration(milliseconds: 150),
      curve: Curves.linear,
    );
  }
}
