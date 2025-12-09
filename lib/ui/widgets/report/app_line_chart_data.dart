import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AppLineChartData extends LineChartBarData {
  AppLineChartData({required List<FlSpot> data, Color color = Colors.green})
    : super(
        spots: data,
        isCurved: true,
        color: color,
        barWidth: 3,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: color.withValues(alpha: 0.15),
        ),
        preventCurveOverShooting: true,
      );
}
