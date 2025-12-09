// lib/models/movement/movement_summary_model.dart

/// Represents a summary view of a stock movement.
///
/// Contains key information for displaying movements in a list (e.g., history log).
class MovementSummaryModel {
  /// Unique identifier of the movement. Can be null if not yet persisted.
  final int? movementId; // Puede ser null al crear

  /// The date and time when the movement occurred.
  final DateTime movedAt;

  /// The quantity of product moved.
  final double amount;

  /// The type of movement (e.g., "Ajuste Positivo", "Venta").
  final String type; // Nombre para mostrar (ej. "Ajuste Positivo")

  // Nombres planos para la UI (Tabla)

  /// The name of the product involved.
  final String productName;

  /// The name of the user who performed the action.
  final String userName;

  /// The name of the depot where the movement happened.
  final String depotName;

  /// Optional observations or notes about the movement.
  final String observation;

  /// Creates a new [MovementSummaryModel].
  MovementSummaryModel({
    required this.movementId,
    required this.movedAt,
    required this.amount,
    required this.type,
    required this.productName,
    required this.userName,
    required this.depotName,
    required this.observation,
  });

  // Factory para leer la respuesta de la lista (GET /movements)

  /// Factory constructor to create a [MovementSummaryModel] from a JSON map.
  ///
  /// Maps flat JSON fields to the model properties. Useful for list responses.
  factory MovementSummaryModel.fromJson(Map<String, dynamic> json) {
    return MovementSummaryModel(
      movementId: json['movement_id'],
      movedAt: DateTime.tryParse(json['moved_at'] ?? '') ?? DateTime.now(),
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      type: json['type'] ?? 'Desconocido',

      // El backend en la lista general suele mandar los nombres planos (JOINs)
      productName: json['product'] ?? 'Producto #${json['product_id']}',
      userName: json['user'] ?? 'Usuario...',
      depotName: json['depot'] ?? 'Depósito...',
      observation: json['observation'] ?? '',
    );
  }
}
