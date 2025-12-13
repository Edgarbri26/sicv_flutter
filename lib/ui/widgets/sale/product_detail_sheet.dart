import 'package:flutter/material.dart';
import 'package:sicv_flutter/models/index.dart';
import 'package:sicv_flutter/ui/widgets/img_product.dart';

class ProductDetailSheet extends StatelessWidget {
  final ProductModel product;

  const ProductDetailSheet({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Cálculos visuales para el stock
    final bool isLowStock = product.totalStock <= product.minStock;
    final Color stockColor = isLowStock ? Colors.red : Colors.green;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      // Limitamos la altura máxima al 85% de la pantalla para que no tape todo
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---------------------------------------------
            // 0. HANDLE BAR (Barra de agarre)
            // ---------------------------------------------
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // ---------------------------------------------
            // 1. ZONA DE IMAGEN Y BADGES
            // ---------------------------------------------
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

                // Badge: Perecedero
                if (product.perishable)
                  Positioned(
                    top: 10,
                    right: 25,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade800,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_filled,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Perecedero",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // ---------------------------------------------
            // 2. CONTENIDO PRINCIPAL
            // ---------------------------------------------
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
                        labelStyle: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2563EB), // Un azul bonito
                        ),
                        backgroundColor: const Color(
                          0xFFEFF6FF,
                        ), // Azul muy claro
                        side: BorderSide.none,
                        shape: const StadiumBorder(),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                      Text(
                        "SKU: ${product.sku ?? 'N/A'}",
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Nombre del Producto
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Descripción
                  Text(
                    product.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ---------------------------------------------
                  // 3. DATOS DUROS (PRECIO Y STOCK)
                  // ---------------------------------------------
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Precio
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "PRECIO UNITARIO",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "\$${product.price.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF059669),
                                  ), // Verde esmeralda
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 6, left: 4),
                                  child: Text(
                                    "USD",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF059669),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "≈ Bs. ${product.priceBs.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),

                        // Divisor vertical sutil
                        Container(
                          width: 1,
                          height: 50,
                          color: Colors.grey[300],
                        ),

                        // Stock
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "DISPONIBILIDAD",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product.totalStock.toStringAsFixed(0),
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: stockColor,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: stockColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isLowStock ? "STOCK BAJO" : "EN STOCK",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: stockColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ---------------------------------------------
            // 4. BOTÓN DE ACCIÓN (Sticky al fondo del contenido)
            // ---------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F2937),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "VER DETALLES TÉCNICOS",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
