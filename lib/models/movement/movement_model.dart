// lib/models/movement/movement_model.dart

import 'package:sicv_flutter/models/movement/movement_summary_model.dart';
import 'package:sicv_flutter/models/product/product_model.dart';

class MovementModel extends MovementSummaryModel {
  // IDs necesarios para lógica interna (Backend)
  final int depotId;
  final int productId;
  final String userCi;
  final bool status;

  // Objetos relacionados completos (Opcional, por si necesitas acceder al stock actual del producto, etc)
  final ProductModel? product; 

  MovementModel({
    required super.movementId,
    required super.movedAt,
    required super.amount,
    required super.type,
    required super.productName,
    required super.userName,
    required super.depotName,
    required super.observation,
    
    // Campos propios del detalle
    required this.depotId,
    required this.productId,
    required this.userCi,
    required this.status,
    this.product,
  });

  // LECTURA COMPLETA (GET /movements/{id})
  factory MovementModel.fromJson(Map<String, dynamic> json) {
    return MovementModel(
      // -- Super (Resumen) --
      movementId: json['movement_id'],
      movedAt: DateTime.tryParse(json['moved_at'] ?? '') ?? DateTime.now(),
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      type: json['type'] ?? 'Desconocido',
      productName: json['product_name'] ?? 'N/A', // Intenta sacar nombre del objeto anidado o del plano
      userName: json['user_name'] ?? 'N/A',
      depotName: json['depot_name'] ?? 'N/A',
      observation: json['observation'] ?? '',

      // -- This (Detalle) --
      depotId: json['depot_id'] ?? 1,
      productId: json['product_id'] ?? 0,
      userCi: json['user_ci'] ?? '',
      status: json['status'] ?? true,
      
      // Si el backend manda el objeto producto completo en el detalle:
      product: json['product'] != null ? ProductModel.fromJson(json['product']) : null,
    );
  }

  // ESCRITURA (Para crear desde el Modal de Ajuste Manual)
  // Aquí usamos 'forCreation' como pediste en tu ejemplo de compras
  factory MovementModel.forCreation({
    required int depotId,
    required ProductModel product, // Pedimos el objeto para sacar ID y Nombre
    required String type,
    required double amount,
    required String userCi,
    String observation = '',
  }) {
    return MovementModel(
      // -- Placeholders visuales para la UI inmediata --
      movementId: null, // El backend lo generará
      movedAt: DateTime.now(),
      amount: amount,
      type: type,
      productName: '',
      userName: '',
      observation: observation,
      depotName: '', // Opcional, puedes dejarlo vacío o agregar otro parámetro si lo necesitas

      // -- Datos reales para el Backend --
      depotId: depotId,
      productId: product.id,
      userCi: userCi,
      status: true,
      product: product,
    );
  }

  // Método para convertir a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'movement_id': movementId, // Puede ir null si es nuevo
      'depot_id': depotId,
      'product_id': productId,
      'type': type,
      'amount': amount,
      'user_ci': userCi,
      'observation': observation,
      'status': status,
      'moved_at': movedAt.toIso8601String(),
    };
  }
}