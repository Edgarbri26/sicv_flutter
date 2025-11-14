// lib/widgets/product_card.dart
import 'package:flutter/material.dart';
import 'package:sicv_flutter/models/product.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product; // Ahora recibe un Product
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ProductCard({
    required this.product,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: SizedBox(
          width: 60,
          height: 60,
          // Muestra la imagen desde la URL, o un ícono si no hay imagen
          child: product.imageUrl != null && product.imageUrl!.isNotEmpty
              ? Image.network(
                  product.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
                )
              : const Icon(Icons.inventory_2_outlined, size: 40),
        ),
        title: Text(product.name),
        subtitle: Text(
          'Stock: ${product.stock} | Precio: \$${product.price.toStringAsFixed(2)}',
        ),
        onTap: onTap,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
