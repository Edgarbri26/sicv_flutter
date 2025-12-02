import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/models/sale/sale_model.dart';

class SaleDetailModal extends StatelessWidget {
  final SaleModel sale;

  const SaleDetailModal({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '\$');
    final date = DateFormat(
      'dd MMM yyyy, HH:mm',
    ).format(sale.soldAt); // Usa sale.createdAt si lo tienes

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // --- CABECERA ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 48),
                const SizedBox(height: 10),
                Text(
                  "Venta #${sale.saleId}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(date, style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 10),
                Text(
                  currency.format(
                    sale.totalUsd,
                  ), // Asegúrate de tener un getter 'total' en SaleModel o calcúlalo
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),

          // --- DETALLES ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildInfoRow(
                  "Cliente",
                  sale.clientName,
                ), // O sale.clientName si tienes el join
                _buildInfoRow("Vendedor", sale.sellerName),
                _buildInfoRow("Método Pago", sale.paymentMethodName),

                const Divider(height: 30),
                const Text(
                  "Productos",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),

                // LISTA DE PRODUCTOS
                ...sale.saleItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${item.amount}x",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Producto: ${item.productName}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ), // Idealmente el nombre
                              Text(
                                currency.format(item.unitCost),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          currency.format(item.amount * item.unitCost),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- BOTÓN CERRAR ---
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Cerrar Recibo"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
