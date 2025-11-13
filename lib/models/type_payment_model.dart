// file: /models/type_payment_model.dart

class TypePaymentModel {
    // Usamos 'final' para promover la inmutabilidad del estado.
    final int? typePaymentId;
    final String name;
    final DateTime? createdAt;
    final DateTime? updatedAt;

    TypePaymentModel({
        this.typePaymentId,
        required this.name,
        this.createdAt,
        this.updatedAt,
    });

    // Factory constructor: Crea una instancia desde un Map (JSON).
    // Maneja la conversión de snake_case (JSON) a camelCase (Dart).
    factory TypePaymentModel.fromJson(Map<String, dynamic> json) {
        return TypePaymentModel(
            typePaymentId: json['type_payment_id'] as int?,
            name: json['name'] as String,
            // Parseamos las fechas ISO 8601 String a objetos DateTime.
            createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
            updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
        );
    }

    // Method: Convierte la instancia de Dart a un Map (JSON).
    // Esto es útil para enviar datos (POST/PUT) a la API.
    Map<String, dynamic> toJson() {
        return {
            'type_payment_id': typePaymentId,
            'name': name,
            'createdAt': createdAt?.toIso8601String(), // Convierte DateTime a String
            'updatedAt': updatedAt?.toIso8601String(),
        };
    }
}