// lib/models/client_model.dart
import 'dart:convert';

// Función para decodificar una lista de clientes
List<ClientModel> clientListFromJson(String str) =>
    List<ClientModel>.from(json.decode(str).map((x) => ClientModel.fromJson(x)));

// Función para decodificar un solo cliente
ClientModel clientFromJson(String str) => ClientModel.fromJson(json.decode(str));

class ClientModel {
  final String clientCi;
  final String name;
  final String phone;
  final String address;
  final bool status;

  ClientModel({
    required this.clientCi,
    required this.name,
    required this.phone,
    required this.address,
    required this.status,
  });

  // Factory constructor para crear una instancia desde un JSON (Map)
  factory ClientModel.fromJson(Map<String, dynamic> json) => ClientModel(
        // Mapea de snake_case (JSON) a camelCase (Dart)
        clientCi: json["client_ci"],
        name: json["name"],
        phone: json["phone"],
        address: json["address"],
        status: json["status"],
      );

  // Método para convertir la instancia a un JSON (Map)
  Map<String, dynamic> toJson() => {
        // Mapea de camelCase (Dart) a snake_case (JSON)
        "client_ci": clientCi,
        "name": name,
        "phone": phone,
        "address": address,
        "status": status,
      };
}