import 'movement_type.dart'; // Importa el enum

class StockMovement {
  final DateTime dateTime;
  final String productName;
  final String? productSku;
  final MovementType movementType;
  final int quantity; // Positivo para entrada, Negativo para salida
  final int stockBefore;
  final int stockAfter;
  final String userName;
  final String? referenceId; // ID de venta/compra

  StockMovement({
    required this.dateTime,
    required this.productName,
    this.productSku,
    required this.movementType,
    required this.quantity,
    required this.stockBefore,
    required this.stockAfter,
    required this.userName,
    this.referenceId,
  });

  
}