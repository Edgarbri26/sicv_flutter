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
              interval: 1,
              showTitles: true,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: labels.length > value.toInt()
                    ? Text(
                        labels[value.toInt()],
                        style: const TextStyle(fontSize: 10),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          // LineChartBarData(
          //   preventCurveOverShooting: true,
          //   spots: provider.salesData,
          //   isCurved: true,
          //   color: Colors.green,
          //   barWidth: 3,
          //   dotData: FlDotData(show: false),
          //   belowBarData: BarAreaData(
          //     show: true,
          //     color: Colors.green.withOpacity(0.15),
          //   ),
          // ),
          ...lineChartBarData,
          // Add comprasData if available
          // if (provider.purchasesData.isNotEmpty)
          //   LineChartBarData(
          //     spots: provider.purchasesData,
          //     isCurved: true,
          //     color: Colors.redAccent,
          //     barWidth: 3,
          //     dotData: FlDotData(show: false),
          //   ),
        ],
      ),
    );
  }
}
