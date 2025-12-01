// lib/models/movement/movement_summary_model.dart

class MovementSummaryModel {
  final int? movementId; // Puede ser null al crear
  final DateTime movedAt;
  final double amount;
  final String type; // Nombre para mostrar (ej. "Ajuste Positivo")
  
  // Nombres planos para la UI (Tabla)
  final String productName;
  final String userName;
  final String depotName;
  final String observation;

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