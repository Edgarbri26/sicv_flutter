import 'package:flutter/material.dart';
import 'package:sicv_flutter/models/index.dart';

class SaleItemCard extends StatelessWidget {
  final SaleItemModel item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onTapAmount;

  const SaleItemCard({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onTapAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white, // Fondo blanco para destacar
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade300), // Borde sutil
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Un poco más de padding
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Alinear arriba
          children: [
            // --- COLUMNA DE INFORMACIÓN ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Nombre del Producto
                  Text(
                    item.productName!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // 2. Información del Depósito (Icono + Texto)
                  Row(
                    children: [
                      Icon(Icons.store, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        item.depotName ?? "Depósito",
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                    ],
                  ),

                  // 3. Información de Vencimiento (Solo si existe)
                  if (item.expirationInfo != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Usamos un icono de alerta si es vencimiento, o calendario normal
                        Icon(Icons.event, size: 14, color: Colors.orange[800]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.expirationInfo!, // Ej: "Vence: 2025-10-10"
                            style: TextStyle(
                              color: Colors.orange[900],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 6),
                  // 4. Precio Unitario
                  Text(
                    "\$${item.unitCost} c/u",
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // --- COLUMNA DE CONTROLES (+ / -) ---
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.remove,
                          color: Colors.red,
                          size: 20,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 35,
                          minHeight: 35,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: onDecrement,
                      ),
                      InkWell(
                        onTap: onTapAmount,
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 30),
                          alignment: Alignment.center,
                          child: Text(
                            "${item.amount}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add,
                          color: Colors.green,
                          size: 20,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 35,
                          minHeight: 35,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: onIncrement,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Subtotal del item
                Text(
                  "\$${(item.unitCost * item.amount).toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
