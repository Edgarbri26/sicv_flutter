import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/models/index.dart';
import 'package:sicv_flutter/providers/auth_provider.dart';
import 'package:sicv_flutter/providers/product_provider.dart';
import 'package:sicv_flutter/providers/sale_provider.dart';
import 'package:sicv_flutter/services/sale_service.dart';
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/text_field_app.dart';
import 'package:sicv_flutter/ui/widgets/product_card.dart';
import 'package:sicv_flutter/ui/widgets/sale/add_product_sheet.dart';
import 'package:sicv_flutter/ui/widgets/sale/category_filter_bar.dart';
import 'package:sicv_flutter/ui/widgets/sale/product_detail_sheet.dart';
import 'package:sicv_flutter/ui/widgets/sale/sale_detail_modal.dart';

class SaleScreen extends ConsumerStatefulWidget {
  const SaleScreen({super.key});

  @override
  ConsumerState<SaleScreen> createState() => SaleScreenState();
}

class SaleScreenState extends ConsumerState<SaleScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;

  final List<SaleItemModel> _itemsForSale = [];
  ClientModel? selectedClient;

  TypePaymentModel? _selectedTypePayment;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(saleSearchTermProvider.notifier).state = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);
    final bool isWide = MediaQuery.of(context).size.width >= 800;
    return Column(
      children: [
        if (isWide) AppBarApp(title: 'Punto de Venta'),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextFieldApp(
            controller: _searchController,
            labelText: 'Buscar por Nombre o SKU',
            prefixIcon: Icons.search,
          ),
        ),
        // uildCategoryFilter(),
        const CategoryFilterBar(),

        Expanded(
          child: productsState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
            data: (products) {
              final filteredProducts = ref.watch(filteredProductsProvider);

              return filteredProducts.isEmpty
                  ? Center(child: Text('No se encontraron productos.'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            mainAxisSpacing: 16.0,
                            crossAxisSpacing: 16.0,
                            childAspectRatio:
                                0.7, // Ajusta la altura (Ancho / Alto)
                          ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        bool isOutOfStock = product.totalStock == 0;

                        return ProductCard(
                          product: product,
                          isOutOfStock: isOutOfStock,
                          onTap: () => _onProductAddedToSale(context, product),
                          onLongPress: () =>
                              _mostrarDialogoDetalleProducto(context, product),
                        );
                      },
                    );
            },
          ),
        ),
      ],
    );
  }

  /// Muestra un BottomSheet con el detalle del producto
  void _mostrarDialogoDetalleProducto(
    BuildContext context,
    ProductModel product,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Permite que el sheet ocupe más altura si es necesario
      backgroundColor:
          Colors.transparent, // Para que se noten los bordes redondeados
      builder: (BuildContext context) {
        return ProductDetailSheet(product: product);
      },
    );
  }

  void showSaleDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SaleDetailModal(
        items: _itemsForSale,
        initialClient: selectedClient,
        initialTypePayment: _selectedTypePayment,
        onClientChanged: (client) => selectedClient = client,
        onTypePaymentChanged: (type) => _selectedTypePayment = type,
        onRestart: () {
          setState(() {
            _itemsForSale.clear();
            selectedClient = null;
            _selectedTypePayment = null;
          });
        },
        onConfirm: (ctx, messengerKey) async {
          await _saveSale(ctx);
        },
      ),
    );
  }

  // Editar Cantidad

  Future<void> _onProductAddedToSale(
    BuildContext context,
    ProductModel product,
  ) async {
    // 1. Esperamos a que el modal se cierre y nos devuelva un SaleItemModel (o null)
    final SaleItemModel? newItem = await showModalBottomSheet<SaleItemModel>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext modalContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalContext).viewInsets.bottom,
          ),
          // child: AddProductSheetContent(product: product),
          child: AddProductSheet(product: product),
        );
      },
    );

    // 2. Si newItem no es null, significa que el usuario confirmó agregar
    if (newItem != null && mounted) {
      setState(() {
        _itemsForSale.add(newItem);
      });

      // Opcional: Feedback visual
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Agregado: ${newItem.productName}"),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _saveSale(BuildContext context) async {
    // 1. Validaciones PRIMERO
    if (_itemsForSale.isEmpty) {
      return;
    }

    if (selectedClient == null) {
      return;
    }

    if (_selectedTypePayment == null) {
      return;
    }

    final user = ref.read(authProvider).value;

    if (user == null) {
      return;
    }
    // -----------------------

    // 2. Preparar los datos
    List<SaleItemModel> saleItems = _itemsForSale.map((item) {
      return SaleItemModel(
        productId: item.productId,
        amount: item.amount,
        unitPriceUsd: item.unitPriceUsd,
        unitPriceBs: item.unitPriceBs,
        depotId: item.depotId, // ID del depósito
      );
    }).toList();

    // 3. Crear el objeto venta
    final SaleModel sale = SaleModel.forCreation(
      clientCi: selectedClient!.clientCi,
      userCi: user.userCi, // Usamos la variable 'user' que extrajimos arriba
      typePaymentId: _selectedTypePayment!.typePaymentId,
      items: saleItems,
    );

    // 4. Enviar al Backend
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await SaleService().createSale(sale);

      // 🔄 Actualizamos el stock de productos
      // Esto disparará automáticamente el listener del SlowStockNotifierService
      await ref.read(productsProvider.notifier).refresh();

      if (mounted) Navigator.of(context).pop(); // Cerrar loading

      // 5. ÉXITO
      if (mounted) {
        Navigator.of(
          context,
        ).pop(); // Cierra el modal de confirmación si existe

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Venta registrada exitosamente.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        ref.invalidate(productsProvider);

        setState(() {
          _itemsForSale.clear();
          selectedClient = null;
          _selectedTypePayment = null;
        });
      }
    } on Exception catch (e) {
      // Manejo genérico de excepciones
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop(); // Cerrar loading si sigue abierto
      }

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content: Text(e.toString().replaceAll("Exception: ", "")),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }
  }
}
