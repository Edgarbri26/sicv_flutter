import 'dart:convert';

// Función para decodificar una lista
List<DepotSummaryModel> depotListFromJson(String str) =>
    List<DepotSummaryModel>.from(json.decode(str).map((x) => DepotSummaryModel.fromJson(x)));

// Función para decodificar un solo objeto
DepotSummaryModel depotFromJson(String str) => DepotSummaryModel.fromJson(json.decode(str));

class DepotSummaryModel {
  final int depotId;
  final String name;
  final String location;

  DepotSummaryModel({
    required this.depotId,
    required this.name,
    required this.location,
  });

  factory DepotSummaryModel.fromJson(Map<String, dynamic> json) => DepotSummaryModel(
        depotId: json["depot_id"],
        name: json["name"],
        location: json["location"],
      );

  Map<String, dynamic> toJson() => {
        "depot_id": depotId,
        "name": name,
        "location": location,
      };
}