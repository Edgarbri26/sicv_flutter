import 'package:flutter/material.dart';
import 'package:sicv_flutter/models/product/product_model.dart';
import 'package:sicv_flutter/ui/widgets/img_product.dart';
import 'package:sicv_flutter/core/theme/app_sizes.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isOutOfStock;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ProductCard({
    super.key,
    required this.product,
    required this.isOutOfStock,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLowStock =
        product.totalStock <= product.minStock && !isOutOfStock;
    final Color stockColor = isOutOfStock
        ? Colors.red
        : (isLowStock ? Colors.orange : Colors.green);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusL),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isLowStock || isOutOfStock
              ? stockColor.withOpacity(0.3)
              : Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusL),
          onLongPress: onLongPress,
          onTap: isOutOfStock ? null : onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---------------------------------------------------------
              // 1. ZONA DE IMAGEN (Reducida ligeramente para dar espacio al texto)
              // ---------------------------------------------------------
              Expanded(
                flex: 9, // Antes 5 (aprox 45% del alto)
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppSizes.borderRadiusL),
                      ),
                      child: Opacity(
                        opacity: isOutOfStock ? 0.6 : 1.0,
                        child: SizedBox(
                          width: double.infinity,
                          child: ImgProduct(imageUrl: product.imageUrl ?? ''),
                        ),
                      ),
                    ),

                    // Badge: Perecedero
                    if (product.perishable)
                      Positioned(
                        top: 5,
                        right: 5,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              const BoxShadow(
                                color: Colors.black12,
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.access_time_filled,
                            color: Colors.orange,
                            size: 14,
                          ),
                        ),
                      ),

                    // Badge: Agotado
                    if (isOutOfStock)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.error.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "AGOTADO",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onError,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ---------------------------------------------------------
              // 2. ZONA DE INFORMACIÓN (Aumentada para evitar overflow)
              // ---------------------------------------------------------
              Expanded(
                flex: 11, // Antes 4 (Ahora tiene 55% del alto)
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ), // Padding reducido
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // --- TÍTULO Y CATEGORÍA ---
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.category.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).hintColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            product.name,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                  height: 1.1,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),

                      // --- PRECIOS Y STOCK ---
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Precio USD
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                "\$${product.price.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: isOutOfStock
                                      ? Theme.of(context).disabledColor
                                      : const Color(0xFF059669),
                                ),
                              ),
                              const SizedBox(width: 2),
                              if (!isOutOfStock)
                                const Text(
                                  "USD",
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF059669),
                                  ),
                                ),
                            ],
                          ),

                          // Precio Bs (Usamos FittedBox para evitar salto de línea)
                          SizedBox(
                            height:
                                16, // Altura fija forzada para evitar expansión
                            child: FittedBox(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Bs. ${product.priceBs.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Theme.of(context).hintColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Indicador de Stock
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: stockColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 10,
                                  color: stockColor,
                                ),
                                const SizedBox(width: 3),
                                Flexible(
                                  // Evita overflow horizontal
                                  child: Text(
                                    "Stock: ${product.totalStock.toStringAsFixed(0)}",
                                    style: TextStyle(
                                      color: stockColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
