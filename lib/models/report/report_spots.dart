import 'package:sicv_flutter/models/report/spot_model.dart';

class ReportSpots {
  final List<SpotModel> spots;
  final int total;
  final List<String> labels;
  final List<String> labelsShort;
  final String filter;

  ReportSpots({
    required this.spots,
    required this.total,
    required this.labels,
    required this.labelsShort,
    required this.filter,
  });

  factory ReportSpots.fromJson(Map<String, dynamic> json) {
    return ReportSpots(
      spots: List<SpotModel>.from(
        json['spots'].map((x) => SpotModel.fromJson(x)),
      ),
      total: (json['total'] as num).toInt(),
      labels: List<String>.from(json['labels'].map((x) => x)),
      labelsShort: List<String>.from(json['labelsShort'].map((x) => x)),
      filter: json['filter'],
    );
  }
}