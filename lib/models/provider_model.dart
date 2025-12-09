import 'dart:convert';

/// Decodes a JSON string into a list of [ProviderModel] objects.
List<ProviderModel> providerListFromJson(String str) =>
    List<ProviderModel>.from(
      json.decode(str).map((x) => ProviderModel.fromJson(x)),
    );

/// Decodes a JSON string into a single [ProviderModel] object.
ProviderModel providerFromJson(String str) =>
    ProviderModel.fromJson(json.decode(str));

/// Represents a supplier or provider in the inventory system.
class ProviderModel {
  /// Unique identifier for the provider.
  final int id;

  /// The name of the provider.
  final String name;

  /// The location or address of the provider.
  final String located;

  /// The active status of the provider.
  final bool status;

  /// Creates a new [ProviderModel].
  ProviderModel({
    required this.id,
    required this.name,
    required this.located,
    required this.status,
  });

  /// Factory constructor to create a [ProviderModel] from a JSON map.
  factory ProviderModel.fromJson(Map<String, dynamic> json) => ProviderModel(
    id: json["provider_id"],
    name: json["name"],
    located: json["located"],
    status: json["status"],
  );

  /// Converts this [ProviderModel] instance to a JSON map.
  Map<String, dynamic> toJson() => {
    "provider_id": id,
    "name": name,
    "located": located,
    "status": status,
  };
}
