// lib/ui/pages/screen/sale_screen.dart

import 'package:flutter/material.dart';
import 'package:sicv_flutter/models/category.dart';
import 'package:sicv_flutter/models/product.dart'; // Importa tu modelo Product

class SaleScreen extends StatefulWidget {
  // Acepta la función callback
  final Function(Product) onProductAdded;

  const SaleScreen({
    Key? key,
    required this.onProductAdded,
  }) : super(key: key);

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  // En un futuro, cargarás esto desde tu API
  late List<Product> _todosLosProductos;

  @override
  void initState() {
    super.initState();
    // Simula la carga de productos (DEBERÍAS TRAERLOS DE TU API/BD)
    // Estoy usando los datos de tu inventario como ejemplo
    _todosLosProductos = [
      // Deberías tener un servicio que te dé la lista completa
      // de productos que puedes vender.
      // Por ahora, usaré datos ficticios.
      Product(id: 1, name: 'Harina PAN', description: '...', price: 1.40, stock: 50, category: Category(id: 1, name: 'Alimentos'), sku: 'ALI-001'),
      Product(id: 2, name: 'Cigarros Marlboro', description: '...', price: 5.99, stock: 5, category: Category(id: 2, name: 'Tabaco'), sku: 'TAB-001'),
      Product(id: 3, name: 'Café', description: '...', price: 10.99, stock: 0, category: Category(id: 3, name: 'Bebidas'), sku: 'BEB-001'),
      Product(id: 4, name: 'Gaseosa 2L', description: '...', price: 2.5, stock: 50, category: Category(id: 3, name: 'Bebidas'), sku: 'BEB-002'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Te recomiendo un GridView para un POS
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 columnas
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.8, // Ajusta esto para la altura
      ),
      itemCount: _todosLosProductos.length,
      itemBuilder: (context, index) {
        final product = _todosLosProductos[index];
        bool isOutOfStock = product.stock == 0;

        // Tarjeta de producto en el catálogo
        return Card(
          clipBehavior: Clip.antiAlias,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            // Llama al callback cuando se toca
            onTap: isOutOfStock 
                ? null // Deshabilita el 'onTap' si no hay stock
                : () => widget.onProductAdded(product),
            child: Opacity(
              opacity: isOutOfStock ? 0.5 : 1.0, // Atenúa si no hay stock
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Imagen del Producto
                  Expanded(
                    flex: 3,
                    child: Container(
                      color: Colors.grey.shade200,
                      child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                          ? Image.network(product.imageUrl!, fit: BoxFit.cover)
                          : Icon(Icons.inventory_2, size: 40, color: Colors.grey.shade400),
                    ),
                  ),
                  // Detalles (Nombre y Precio)
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Spacer(),
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                              fontSize: 16,
                            ),
                          ),
                          if (isOutOfStock)
                            Text(
                              'Agotado',
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 10),
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
      },
    );
  }
}