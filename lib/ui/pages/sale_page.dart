import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sicv_flutter/core/theme/app_sizes.dart';
import 'package:sicv_flutter/models/index.dart';
import 'package:sicv_flutter/providers/auth_provider.dart';
import 'package:sicv_flutter/providers/product_provider.dart';
import 'package:sicv_flutter/providers/sale_provider.dart';
import 'package:sicv_flutter/services/sale_service.dart';
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/my_side_bar.dart';
import 'package:sicv_flutter/ui/widgets/atomic/text_field_app.dart';
import 'package:sicv_flutter/ui/widgets/product_card.dart';
import 'package:sicv_flutter/ui/widgets/sale/add_product_sheet.dart';
import 'package:sicv_flutter/ui/widgets/sale/category_filter_bar.dart';
import 'package:sicv_flutter/ui/widgets/sale/product_detail_sheet.dart';
import 'package:sicv_flutter/ui/widgets/sale/sale_detail_modal.dart';
import 'package:sicv_flutter/ui/widgets/wide_layuout.dart';
import 'package:sidebarx/sidebarx.dart';

class SalePage extends ConsumerStatefulWidget {
  final SidebarXController controller;

  const SalePage({super.key, required this.controller});

  @override
  ConsumerState<SalePage> createState() => _SalePageState();
}

class _SalePageState extends ConsumerState<SalePage> {
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

  Future<void> _onProductAddedToSale(
    BuildContext context,
    ProductModel product,
  ) async {
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
          child: AddProductSheet(product: product),
        );
      },
    );

    if (newItem != null && mounted) {
      setState(() {
        _itemsForSale.add(newItem);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Agregado: ${newItem.productName}"),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors
              .green, // O Theme.of(context).colorScheme.primary si prefieres
        ),
      );
    }
  }

  void _mostrarDialogoDetalleProducto(
    BuildContext context,
    ProductModel product,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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

  Future<void> _saveSale(BuildContext context) async {
    if (_itemsForSale.isEmpty) return;
    if (selectedClient == null) return;
    if (_selectedTypePayment == null) return;

    final user = ref.read(authProvider).value;
    if (user == null) return;

    List<SaleItemModel> saleItems = _itemsForSale.map((item) {
      return SaleItemModel(
        productId: item.productId,
        amount: item.amount,
        unitPriceUsd: item.unitPriceUsd,
        unitPriceBs: item.unitPriceBs,
        depotId: item.depotId,
        stockLotId: item.stockLotId,
      );
    }).toList();

    final SaleModel sale = SaleModel.forCreation(
      clientCi: selectedClient!.clientCi,
      userCi: user.userCi,
      typePaymentId: _selectedTypePayment!.typePaymentId,
      items: saleItems,
    );

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await SaleService().createSale(sale);
      await ref.read(productsProvider.notifier).refresh();

      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Venta registrada exitosamente.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        ref.invalidate(productsProvider);

        for (var item in _itemsForSale) {
          ref.invalidate(productStockDetailProvider(item.productId));
        }

        setState(() {
          _itemsForSale.clear();
          selectedClient = null;
          _selectedTypePayment = null;
        });
      }
    } on Exception catch (e) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);

    // Contenido de la pantalla de venta (extraído y adaptado de SaleScreen)
    Widget saleContent = Column(
      children: [
        // NOTA: El AppBar se maneja en el Scaffold principal de SalePage
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextFieldApp(
            controller: _searchController,
            labelText: 'Buscar por Nombre o SKU',
            prefixIcon: Icons.search,
          ),
        ),
        const CategoryFilterBar(),
        Expanded(
          child: productsState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
            data: (products) {
              final filteredProducts = ref.watch(filteredProductsProvider);

              return filteredProducts.isEmpty
                  ? const Center(child: Text('No se encontraron productos.'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            mainAxisSpacing: 16.0,
                            crossAxisSpacing: 16.0,
                            childAspectRatio: 0.7,
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= AppSizes.breakpoint;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: !isWide ? AppBarApp(title: 'Venta') : null,
          drawer: isWide ? null : MySideBar(controller: widget.controller),
          body: isWide
              ? WideLayout(
                  controller: widget.controller,
                  appbartitle: 'Venta',
                  child: saleContent,
                )
              // ? Row(
              //     children: [
              //       MySideBar(controller: widget.controller),
              //       Expanded(
              //         child: Padding(
              //           padding: const EdgeInsets.only(top: 16.0),
              //           child: saleContent,
              //         ),
              //       ),
              //     ],
              //   )
              : saleContent,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              showSaleDetail(context); // Llama al método local
            },
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(
              Symbols.shopping_cart_checkout,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            label: Text(
              "Ver Orden",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
