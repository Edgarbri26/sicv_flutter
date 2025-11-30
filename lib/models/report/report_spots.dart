import 'package:sicv_flutter/models/report/spot_model.dart';

class ReportSpots {
  final List<SpotModel> spots;
  final int total;
  final List<String> labels;
  final String filter;

  ReportSpots({
    required this.spots,
    required this.total,
    required this.labels,
    required this.filter,
  });

  factory ReportSpots.fromJson(Map<String, dynamic> json) {
    return ReportSpots(
      spots: List<SpotModel>.from(
        json['spots'].map((x) => SpotModel.fromJson(x)),
      ),
      total: (json['total'] as num).toInt(),
      labels: List<String>.from(json['labels'].map((x) => x)),
      filter: json['filter'],
    );
  }
}

// {
//         "filter": "week",
//         "labels": [
//             "Lun",
//             "Mar",
//             "Mié",
//             "Jue",
//             "Vie",
//             "Sáb",
//             "Dom"
//         ],
//         "spots": [
//             {
//                 "index": 0,
//                 "values": 5
//             },
//             {
//                 "index": 1,
//                 "values": 0
//             },
//             {
//                 "index": 2,
//                 "values": 0
//             },
//             {
//                 "index": 3,
//                 "values": 0
//             },
//             {
//                 "index": 4,
//                 "values": 0
//             },
//             {
//                 "index": 5,
//                 "values": 0
//             },
//             {
//                 "index": 6,
//                 "values": 0
//             }
//         ],
//         "total": 5
//     }
