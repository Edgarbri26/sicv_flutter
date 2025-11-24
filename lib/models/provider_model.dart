import 'dart:convert';

// Función para decodificar una lista
List<ProviderModel> providerListFromJson(String str) =>
    List<ProviderModel>.from(
      json.decode(str).map((x) => ProviderModel.fromJson(x)),
    );

// Función para decodificar un solo objeto
ProviderModel providerFromJson(String str) =>
    ProviderModel.fromJson(json.decode(str));

class ProviderModel {
  final int id;
  final String name;
  final String located;
  final bool status;

  ProviderModel({
    required this.id,
    required this.name,
    required this.located,
    required this.status,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) => ProviderModel(
    id: json["provider_id"],
    name: json["name"],
    located: json["located"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "provider_id": id,
    "name": name,
    "located": located,
    "status": status,
  };
}
