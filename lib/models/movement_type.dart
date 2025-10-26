import 'package:flutter/material.dart';

enum MovementType {
  venta('Venta', Icons.arrow_downward, Colors.red),
  compra('Compra', Icons.arrow_upward, Colors.green),
  ajustePositivo('Ajuste (+)', Icons.add_circle_outline, Colors.blue),
  ajusteNegativo('Ajuste (-)', Icons.remove_circle_outline, Colors.orange),
  devolucionCliente('Dev. Cliente', Icons.undo, Colors.lightGreen),
  devolucionProveedor('Dev. Proveedor', Icons.redo, Colors.deepOrange);

  const MovementType(this.displayName, this.icon, this.color);
  final String displayName;
  final IconData icon;
  final Color color;
}