// lib/models/client_model.dart
import 'dart:convert';

/// Decodes a JSON string into a list of [ClientModel] objects.
List<ClientModel> clientListFromJson(String str) => List<ClientModel>.from(
  json.decode(str).map((x) => ClientModel.fromJson(x)),
);

/// Decodes a JSON string into a single [ClientModel] object.
ClientModel clientFromJson(String str) =>
    ClientModel.fromJson(json.decode(str));

/// Represents a client in the system.
class ClientModel {
  /// Unique identifier (Identity Card) for the client.
  final String clientCi;

  /// The full name of the client.
  final String name;

  /// The phone number of the client.
  final String phone;

  /// The physical address of the client.
  final String address;

  /// The active status of the client.
  final bool status;

  /// Creates a new [ClientModel].
  ClientModel({
    required this.clientCi,
    required this.name,
    required this.phone,
    required this.address,
    required this.status,
  });

  /// Factory constructor to create a [ClientModel] from a JSON map.
  ///
  /// Maps snake_case JSON keys to camelCase Dart properties.
  factory ClientModel.fromJson(Map<String, dynamic> json) => ClientModel(
    // Mapea de snake_case (JSON) a camelCase (Dart)
    clientCi: json["client_ci"],
    name: json["name"],
    phone: json["phone"],
    address: json["address"],
    status: json["status"],
  );

  /// Converts this [ClientModel] instance to a JSON map.
  ///
  /// Maps camelCase Dart properties to snake_case JSON keys.
  Map<String, dynamic> toJson() => {
    // Mapea de camelCase (Dart) a snake_case (JSON)
    "client_ci": clientCi,
    "name": name,
    "phone": phone,
    "address": address,
    "status": status,
  };
}
