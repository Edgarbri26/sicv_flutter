import 'dart:convert';

/// Decodes a JSON string into a list of [DepotModel] objects.
List<DepotModel> depotListFromJson(String str) =>
    List<DepotModel>.from(json.decode(str).map((x) => DepotModel.fromJson(x)));

/// Decodes a JSON string into a single [DepotModel] object.
DepotModel depotFromJson(String str) => DepotModel.fromJson(json.decode(str));

/// Represents a warehouse or depot location in the inventory system.
class DepotModel {
  /// Unique identifier for the depot.
  final int depotId;

  /// The name of the depot.
  final String name;

  /// The physical location or address of the depot.
  final String location;

  /// The active status of the depot.
  final bool status;

  /// Creates a new [DepotModel].
  DepotModel({
    required this.depotId,
    required this.name,
    required this.location,
    required this.status,
  });

  /// Factory constructor to create a [DepotModel] from a JSON map.
  factory DepotModel.fromJson(Map<String, dynamic> json) => DepotModel(
    depotId: json["depot_id"],
    name: json["name"],
    location: json["location"],
    status: json["status"],
  );

  /// Converts this [DepotModel] instance to a JSON map.
  Map<String, dynamic> toJson() => {
    "depot_id": depotId,
    "name": name,
    "location": location,
    "status": status,
  };
}
