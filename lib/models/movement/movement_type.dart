import 'package:flutter/material.dart';

/// Enumerates the standard types of stock movements in the system.
///
/// Each enum value holds display properties like [displayName], [icon], and [color].
enum MovementType {
  /// Represents a sale transaction (Stock decrease).
  venta('Venta', Icons.arrow_downward, Colors.red),

  /// Represents a purchase transaction (Stock increase).
  compra('Compra', Icons.arrow_upward, Colors.green),

  /// Represents a manual positive adjustment (Stock increase).
  ajustePositivo('Ajuste Positivo', Icons.add_circle_outline, Colors.blue),

  /// Represents a manual negative adjustment (Stock decrease).
  ajusteNegativo('Ajuste Negativo', Icons.remove_circle_outline, Colors.orange),

  /// Represents a return from a customer (Stock increase).
  devolucionCliente('Dev. Cliente', Icons.undo, Colors.lightGreen),

  /// Represents a return to a provider (Stock decrease).
  devolucionProveedor('Dev. Proveedor', Icons.redo, Colors.deepOrange);

  /// Creates a [MovementType] with specific visual properties.
  const MovementType(this.displayName, this.icon, this.color);

  /// The human-readable name of the movement type.
  final String displayName;

  /// The icon associated with the movement type.
  final IconData icon;

  /// The color associated with the movement type (e.g., Red for decrease, Green for increase).
  final Color color;
}
