import 'purchase_item_input_model.dart'; // Importa el modelo unificado

class PurchaseInputModel { // Cambié el nombre para mayor claridad de que es un input
  final int providerId;
  final String userCi;
  final int typePaymentId;
  final String status; // Asumiendo que es String en el backend
  
  // 💡 La lista unificada que el backend espera
  final List<PurchaseItemInputModel> items; 

  PurchaseInputModel({
    required this.providerId,
    required this.userCi,
    required this.typePaymentId,
    required this.status,
    required this.items, // Un solo array para enviar
  });

  Map<String, dynamic> toJson() {
    return {
      'provider_id': providerId,
      'user_ci': userCi,
      'type_payment_id': typePaymentId,
      'status': status, 
      // 💡 Envía la lista unificada
      'purchase_items': items.map((item) => item.toJson()).toList(), 
    };
  }
}