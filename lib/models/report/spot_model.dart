/// Represents a single point (X, Y) in 2D chart coordination space.
class SpotModel {
  /// The X coordinate value (often represents time index or category index).
  final double x;

  /// The Y coordinate value (often represents amount or quantity).
  final double y;

  /// Creates a new [SpotModel].
  SpotModel({required this.x, required this.y});

  /// Factory constructor to create a [SpotModel] from a JSON map.
  ///
  /// Maps `index` to [x] and `value` to [y].
  factory SpotModel.fromJson(Map<String, dynamic> json) {
    return SpotModel(
      x: double.parse(json['index'].toString()),
      y: double.parse(json['value'].toString()),
    );
  }
}
