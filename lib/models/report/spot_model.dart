class SpotModel {
  final double x;
  final double y;

  SpotModel({required this.x, required this.y});

  factory SpotModel.fromJson(Map<String, dynamic> json) {
    return SpotModel(
      x: double.parse(json['index'].toString()),
      y: double.parse(json['value'].toString()),
    );
  }
}
