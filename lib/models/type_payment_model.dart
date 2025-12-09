// file: /models/type_payment_model.dart

/// Represents a payment type configuration (e.g., Credit Card, Cash).
class TypePaymentModel {
  // Usamos 'final' para promover la inmutabilidad del estado.

  /// Unique identifier for the payment type.
  final int typePaymentId;

  /// The name of the payment type.
  final String name;

  /// The active status of the payment type.
  final bool status;

  /// The timestamp when the payment type record was created.
  final DateTime? createdAt;

  /// The timestamp when the payment type record was last updated.
  final DateTime? updatedAt;

  /// Creates a new [TypePaymentModel].
  TypePaymentModel({
    required this.typePaymentId,
    required this.name,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor: Crea una instancia desde un Map (JSON).
  // Maneja la conversión de snake_case (JSON) a camelCase (Dart).

  /// Factory constructor to create a [TypePaymentModel] from a JSON map.
  factory TypePaymentModel.fromJson(Map<String, dynamic> json) {
    return TypePaymentModel(
      name: json['name'] as String,
      typePaymentId: json['type_payment_id'] as int,
      status: json['status'] as bool,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  // Method: Convierte la instancia de Dart a un Map (JSON).
  // Esto es útil para enviar datos (POST/PUT) a la API.

  /// Converts this [TypePaymentModel] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'type_payment_id': typePaymentId,
      'name': name,
      'status': status,
      'createdAt': createdAt?.toIso8601String(), // Convierte DateTime a String
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
