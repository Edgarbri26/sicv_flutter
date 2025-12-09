import 'dart:convert';

/// Decodes a JSON string into a list of [DepotSummaryModel] objects.
List<DepotSummaryModel> depotListFromJson(String str) =>
    List<DepotSummaryModel>.from(
      json.decode(str).map((x) => DepotSummaryModel.fromJson(x)),
    );

/// Decodes a JSON string into a single [DepotSummaryModel] object.
DepotSummaryModel depotFromJson(String str) =>
    DepotSummaryModel.fromJson(json.decode(str));

/// Represents a summary view of a warehouse or depot (e.g., for list views).
class DepotSummaryModel {
  /// Unique identifier for the depot.
  final int depotId;

  /// The name of the depot.
  final String name;

  /// The physical location of the depot.
  final String location;

  /// Creates a new [DepotSummaryModel].
  DepotSummaryModel({
    required this.depotId,
    required this.name,
    required this.location,
  });

  /// Factory constructor to create a [DepotSummaryModel] from a JSON map.
  factory DepotSummaryModel.fromJson(Map<String, dynamic> json) =>
      DepotSummaryModel(
        depotId: json["depot_id"],
        name: json["name"],
        location: json["location"],
      );

  /// Converts this [DepotSummaryModel] instance to a JSON map.
  Map<String, dynamic> toJson() => {
    "depot_id": depotId,
    "name": name,
    "location": location,
  };
}
