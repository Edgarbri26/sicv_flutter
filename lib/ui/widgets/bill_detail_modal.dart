import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sicv_flutter/core/utils/date_utils.dart';
import 'package:sicv_flutter/models/sale/sale_model.dart';

class BillDetailModal extends StatelessWidget {
  final SaleModel sale;

  const BillDetailModal({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '\$');
    final date = DateFormatter.format(
      sale.soldAt,
    ); // Usa sale.createdAt si lo tienes

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // --- CABECERA ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  date,
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
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
                  context,
                  "Cliente",
                  sale.clientName,
                ), // O sale.clientName si tienes el join
                _buildInfoRow(context, "Vendedor", sale.sellerName),
                _buildInfoRow(context, "Método Pago", sale.paymentMethodName),

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
                            color: Theme.of(context).cardColor,
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
                              Row(
                                children: [
                                  Text(
                                    currency.format(item.unitPriceUsd),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    currency.format(item.unitPriceBs),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(
                          currency.format(item.amount * item.unitPriceUsd),
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
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
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

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).hintColor)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
