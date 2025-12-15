import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Asegúrate de importar esto para fechas
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/models/index.dart';
import 'package:sicv_flutter/ui/widgets/img_product.dart';

class ProductDetailSheet extends StatelessWidget {
  final ProductModel product;

  const ProductDetailSheet({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final bool isLowStock = product.totalStock <= product.minStock;
    final Color stockColor = isLowStock ? AppColors.danger : AppColors.success;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 0. HANDLE BAR
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // 1. ZONA DE IMAGEN Y BADGES
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      height: 220,
                      width: double.infinity,
                      child: ImgProduct(imageUrl: product.imageUrl ?? ''),
                    ),
                  ),
                ),
                if (product.perishable)
                  Positioned(
                    top: 10,
                    right: 25,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.edit,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.access_time_filled, color: AppColors.secondary, size: 14),
                          SizedBox(width: 4),
                          Text("Perecedero", style: TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // 2. CONTENIDO
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoría y SKU
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        label: Text(product.category.name.toUpperCase()),
                        labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.info),
                        backgroundColor: AppColors.info.withOpacity(0.1),
                        side: BorderSide.none,
                        shape: const StadiumBorder(),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                      Text(
                        "SKU: ${product.sku ?? 'N/A'}",
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, height: 1.1, letterSpacing: -0.5)),
                  const SizedBox(height: 12),
                  Text(product.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.4)),
                  const SizedBox(height: 24),

                  // 3. PRECIO Y STOCK TOTAL
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("PRECIO UNITARIO", style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("\$${product.price.toStringAsFixed(2)}", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.success)),
                                const Padding(padding: EdgeInsets.only(bottom: 6, left: 4), child: Text("USD", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.success))),
                              ],
                            ),
                            Text("≈ Bs. ${product.priceBs.toStringAsFixed(2)}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                          ],
                        ),
                        Container(width: 1, height: 50, color: AppColors.border),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text("DISPONIBILIDAD", style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(product.totalStock.toStringAsFixed(0), style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: stockColor)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: stockColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                              child: Text(isLowStock ? "STOCK BAJO" : "EN STOCK", style: TextStyle(fontSize: 10, color: stockColor, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 4. NUEVA SECCIÓN: DESGLOSE DE DEPÓSITOS
                  const Text(
                    "UBICACIÓN EN INVENTARIO",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Lógica para mostrar lista de lotes o general
                  if (product.perishable)
                    ...product.stockLots.map((lot) => _buildStockRow(
                      depotName: lot.depotName,
                      amount: lot.amount,
                      expiry: lot.expirationDate,
                      isLast: product.stockLots.last == lot,
                    ))
                  else
                    ...product.stockGenerals.map((stock) => _buildStockRow(
                      depotName: stock.depotName,
                      amount: stock.amount,
                      isLast: product.stockGenerals.last == stock,
                    )),
                    
                  if ((product.perishable && product.stockLots.isEmpty) || (!product.perishable && product.stockGenerals.isEmpty))
                     const Padding(
                       padding: EdgeInsets.symmetric(vertical: 10),
                       child: Text("No hay desglose de stock disponible.", style: TextStyle(color: Colors.grey)),
                     ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para cada fila de depósito
  Widget _buildStockRow({
    required String depotName,
    required int amount,
    DateTime? expiry,
    bool isLast = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.6)),
        boxShadow: [
           BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono de Depósito
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warehouse_rounded, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          
          // Información del Depósito y Fecha
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  depotName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                if (expiry != null)
                  Text(
                    "Vence: ${DateFormat('dd/MM/yyyy').format(expiry)}",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),

          // Cantidad
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              "$amount Unid.",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}