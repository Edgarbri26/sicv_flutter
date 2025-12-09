// lib/models/movement/movement_model.dart

import 'package:sicv_flutter/models/movement/movement_summary_model.dart';
import 'package:sicv_flutter/models/product/product_model.dart';

/// Represents the detailed data of a stock movement.
///
/// Extends [MovementSummaryModel] to include specific IDs and status fields required
/// for backend operations and full detail views.
class MovementModel extends MovementSummaryModel {
  // IDs necesarios para lógica interna (Backend)

  /// Unique identifier of the depot involved in the movement.
  final int depotId;

  /// Unique identifier of the product involved in the movement.
  final int productId;

  /// Unique identifier (Identity Card) of the user who performed the movement.
  final String userCi;

  /// The active status of the movement record.
  final bool status;

  // Objetos relacionados completos (Opcional, por si necesitas acceder al stock actual del producto, etc)

  /// The full product object associated with this movement (optional).
  final ProductModel? product;

  /// Creates a new [MovementModel].
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

  /// Factory constructor to create a [MovementModel] from a JSON map.
  ///
  /// This is typically used when fetching full details of a movement (e.g., GET /movements/{id}).
  /// Handles parsing of both summary fields (inherited) and detail fields.
  factory MovementModel.fromJson(Map<String, dynamic> json) {
    return MovementModel(
      // -- Super (Resumen) --
      movementId: json['movement_id'],
      movedAt: DateTime.tryParse(json['moved_at'] ?? '') ?? DateTime.now(),
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      type: json['type'] ?? 'Desconocido',
      productName:
          json['product_name'] ??
          'N/A', // Intenta sacar nombre del objeto anidado o del plano
      userName: json['user_name'] ?? 'N/A',
      depotName: json['depot_name'] ?? 'N/A',
      observation: json['observation'] ?? '',

      // -- This (Detalle) --
      depotId: json['depot_id'] ?? 1,
      productId: json['product_id'] ?? 0,
      userCi: json['user_ci'] ?? '',
      status: json['status'] ?? true,

      // Si el backend manda el objeto producto completo en el detalle:
      product: json['product'] != null
          ? ProductModel.fromJson(json['product'])
          : null,
    );
  }

  // ESCRITURA (Para crear desde el Modal de Ajuste Manual)
  // Aquí usamos 'forCreation' como pediste en tu ejemplo de compras

  /// Factory method to create a [MovementModel] specifically for creating a new record.
  ///
  /// This sets up a "temporary" instance with necessary data to be sent to the backend.
  /// [movementId] is null as it hasn't been created yet.
  factory MovementModel.forCreation({
    required int depotId,
    required ProductModel product, // Pedimos el objeto para sacar ID y Nombre
    required String type,
    required double amount,
    required String userCi,
    String observation = '',
    String? e,
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
      depotName:
          '', // Opcional, puedes dejarlo vacío o agregar otro parámetro si lo necesitas
      // -- Datos reales para el Backend --
      depotId: depotId,
      productId: product.id,
      userCi: userCi,
      status: true,
      product: product,
    );
  }

  // Método para convertir a JSON para enviar al backend

  /// Converts this [MovementModel] instance to a JSON map.
  ///
  /// Useful for sending data to the backend (e.g., creating or updating a movement).
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
