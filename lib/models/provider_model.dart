import 'dart:convert';

// Función para decodificar una lista
List<ProviderModel> providerListFromJson(String str) =>
    List<ProviderModel>.from(json.decode(str).map((x) => ProviderModel.fromJson(x)));

// Función para decodificar un solo objeto
ProviderModel providerFromJson(String str) => ProviderModel.fromJson(json.decode(str));

class ProviderModel {
  final int providerId;
  final String name;
  final String located;

  ProviderModel({
    required this.providerId,
    required this.name,
    required this.located
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) => ProviderModel(
        providerId: json["provider_id"],
        name: json["name"],
        located: json["located"]
      );

  Map<String, dynamic> toJson() => {
        "provider_id": providerId,
        "name": name,
        "located": located
      };
}