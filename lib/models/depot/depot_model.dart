import 'dart:convert';

// Función para decodificar una lista
List<DepotModel> depotListFromJson(String str) =>
    List<DepotModel>.from(json.decode(str).map((x) => DepotModel.fromJson(x)));

// Función para decodificar un solo objeto
DepotModel depotFromJson(String str) => DepotModel.fromJson(json.decode(str));

class DepotModel {
  final int depotId;
  final String name;
  final String location;
  final bool status;

  DepotModel({
    required this.depotId,
    required this.name,
    required this.location,
    required this.status,
  });

  factory DepotModel.fromJson(Map<String, dynamic> json) => DepotModel(
        depotId: json["depot_id"],
        name: json["name"],
        location: json["location"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "depot_id": depotId,
        "name": name,
        "location": location,
        "status": status,
      };
}