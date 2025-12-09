import 'package:sicv_flutter/models/report/spot_model.dart';

/// Represents a dataset for chart reporting (e.g., line charts, bar charts).
///
/// Contains the data points ([spots]), a total aggregated value, and axis labels.
class ReportSpots {
  /// The list of data points (X, Y) for the chart.
  final List<SpotModel> spots;

  /// The total value aggregated from the data (e.g., total sales amount).
  final int total;

  /// List of full labels for the X-axis (e.g., ["Lunes", "Martes"]).
  final List<String> labels;

  /// List of short labels for the X-axis (e.g., ["L", "M"]).
  final List<String> labelsShort;

  /// The filter context applied to this data set (e.g., "week", "month").
  final String filter;

  /// Creates a new [ReportSpots] container.
  ReportSpots({
    required this.spots,
    required this.total,
    required this.labels,
    required this.labelsShort,
    required this.filter,
  });

  /// Factory constructor to create a [ReportSpots] from a JSON map.
  factory ReportSpots.fromJson(Map<String, dynamic> json) {
    return ReportSpots(
      spots: json['spots'] != null
          ? List<SpotModel>.from(
              json['spots'].map((x) => SpotModel.fromJson(x)),
            )
          : [],
      total: json['total'] != null ? (json['total'] as num).toInt() : 0,
      labels: json['labels'] != null
          ? List<String>.from(json['labels'].map((x) => x))
          : [],
      labelsShort: json['labelsShort'] != null
          ? List<String>.from(json['labelsShort'].map((x) => x))
          : [],
      filter: json['filter'] ?? '',
    );
  }
}
