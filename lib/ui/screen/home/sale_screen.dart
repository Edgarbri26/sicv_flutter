import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/models/index.dart';
import 'package:sicv_flutter/providers/auth_provider.dart';
import 'package:sicv_flutter/providers/cliente_provider.dart';
import 'package:sicv_flutter/providers/product_provider.dart';
import 'package:sicv_flutter/providers/sale_provider.dart';
import 'package:sicv_flutter/providers/type_payment_provider.dart';
import 'package:sicv_flutter/services/client_service.dart';
import 'package:sicv_flutter/services/sale_service.dart';
import 'package:sicv_flutter/ui/skeletom/cartd_sceleton.dart';
import 'package:sicv_flutter/ui/widgets/add_client_form.dart';
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/button_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/drop_down_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/search_text_field_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/text_field_app.dart';
import 'package:sicv_flutter/ui/widgets/product_card.dart';
import 'package:sicv_flutter/ui/widgets/sale/add_product_sheet.dart';
import 'package:sicv_flutter/ui/widgets/sale/sale_item_card.dart';
import 'package:sicv_flutter/ui/widgets/sale/category_filter_bar.dart';
import 'package:sicv_flutter/ui/widgets/sale/product_detail_sheet.dart';

class SaleScreen extends ConsumerStatefulWidget {
  const SaleScreen({super.key});

  @override
  ConsumerState<SaleScreen> createState() => SaleScreenState();
}

class SaleScreenState extends ConsumerState<SaleScreen> {
  final TextEditingController _searchController = TextEditingController();

  final TextEditingController _searchClientController = TextEditingController();

  Timer? _debounce;

  final List<SaleItemModel> _itemsForSale = [];
  ClientModel? selectedClient;

  TypePaymentModel? _selectedTypePayment;
  final FocusNode _paymentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchClientController.dispose();
    _searchController.dispose();
    _paymentFocusNode.dispose();
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
    // Key para gestionar el formulario
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    // Key para el ScaffoldMessenger del modal
    final GlobalKey<ScaffoldMessengerState> modalMessengerKey =
        GlobalKey<ScaffoldMessengerState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que ocupe casi toda la pantalla
      backgroundColor:
          Colors.transparent, // Transparente para ver el borde redondeado
      builder: (BuildContext modalContext) {
        // SOLUCIÓN SNACKBAR:
        // Envolvemos todo en un ScaffoldMessenger para que los SnackBars se muestren AQUÍ.
        return ScaffoldMessenger(
          key: modalMessengerKey,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            // Usamos DraggableScrollableSheet para un efecto de deslizamiento profesional
            body: DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Consumer(
                    builder: (context, ref, child) {
                      // Providers
                      final typePaymentsState = ref.watch(typePaymentProvider);
                      // Escuchar cambios de cliente si es necesario para refrescar la UI
                      ref.watch(clientProvider);

                      // StatefulBuilder para manejar cambios dentro del modal (como la cantidad)
                      return StatefulBuilder(
                        builder: (BuildContext context, StateSetter modalSetState) {
                          return Form(
                            key: formKey,
                            child: Column(
                              children: [
                                // --- 1. HANDLE BAR (Barra gris superior) ---
                                const SizedBox(height: 12),
                                Center(
                                  child: Container(
                                    width: 40,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),

                                // --- 2. TÍTULO ---
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  child: Text(
                                    "Detalles de la Venta",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const Divider(height: 1),

                                Expanded(
                                  child: ListView(
                                    controller:
                                        scrollController, // Vincula el scroll del sheet
                                    padding: const EdgeInsets.all(16),
                                    children: [
                                      // --- A. SECCIÓN CLIENTE ---
                                      const Text(
                                        "Cliente",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Autocomplete<ClientModel>(
                                              optionsBuilder:
                                                  (
                                                    TextEditingValue
                                                    textEditingValue,
                                                  ) {
                                                    if (textEditingValue
                                                        .text
                                                        .isEmpty) {
                                                      return const Iterable<
                                                        ClientModel
                                                      >.empty();
                                                    }
                                                    final currentClients =
                                                        ref
                                                            .read(
                                                              clientProvider,
                                                            )
                                                            .value ??
                                                        [];
                                                    final term =
                                                        textEditingValue.text
                                                            .toLowerCase();
                                                    return currentClients.where(
                                                      (ClientModel option) {
                                                        return option.name
                                                                .toLowerCase()
                                                                .contains(
                                                                  term,
                                                                ) ||
                                                            option.clientCi
                                                                .toLowerCase()
                                                                .contains(term);
                                                      },
                                                    );
                                                  },
                                              displayStringForOption:
                                                  (ClientModel option) =>
                                                      "CI:${option.clientCi} ${option.name} ",
                                              onSelected:
                                                  (ClientModel selection) {
                                                    modalSetState(() {
                                                      selectedClient =
                                                          selection;
                                                    });
                                                    _paymentFocusNode
                                                        .requestFocus();
                                                  },
                                              fieldViewBuilder:
                                                  (
                                                    context,
                                                    textEditingController,
                                                    focusNode,
                                                    onFieldSubmitted,
                                                  ) {
                                                    return SearchTextFieldApp(
                                                      autofocus: true,
                                                      controller:
                                                          textEditingController,
                                                      focusNode: focusNode,
                                                      labelText:
                                                          'Buscar Cliente',
                                                      prefixIcon: Icons.search,
                                                      onSubmitted:
                                                          (String val) {
                                                            onFieldSubmitted();
                                                          },
                                                      validator: (value) {
                                                        if (selectedClient ==
                                                            null) {
                                                          return 'Seleccione un cliente';
                                                        }
                                                        return null;
                                                      },
                                                    );
                                                  },
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          ButtonApp(
                                            text: "Nuevo",
                                            onPressed: () async {
                                              // 1. Abrimos el modal directamente AQUÍ
                                              final bool? clientWasAdded =
                                                  await showModalBottomSheet<
                                                    bool
                                                  >(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    backgroundColor:
                                                        AppColors.primary,
                                                    builder: (ctx) =>
                                                        AddClientForm(),
                                                  );

                                              // 2. Si se agregó, refrescamos la lista
                                              if (clientWasAdded == true) {
                                                if (!context.mounted) return;
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Cliente agregado correctamente',
                                                    ),
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                );

                                                // Refrescamos el provider
                                                await ref
                                                    .read(
                                                      clientProvider.notifier,
                                                    )
                                                    .refresh();

                                                if (!context.mounted) return;

                                                modalSetState(() {
                                                  final newClients =
                                                      ref
                                                          .read(clientProvider)
                                                          .value ??
                                                      [];
                                                  if (newClients.isNotEmpty) {
                                                    selectedClient =
                                                        newClients.last;
                                                  }
                                                });
                                              }
                                            },
                                          ),
                                        ],
                                      ),

                                      // Tarjeta de Cliente Seleccionado
                                      if (selectedClient != null)
                                        Container(
                                          margin: const EdgeInsets.only(
                                            top: 10,
                                          ),
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.check_circle,
                                                color: AppColors.primary,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  "Seleccionado: ${selectedClient!.name}",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                      const SizedBox(height: 20),

                                      // ---  TIPO DE PAGO ---
                                      typePaymentsState.when(
                                        loading: () =>
                                            const CategoryLoadingSkeleton(),
                                        error: (error, stack) => Center(
                                          child: Text('Error: $error'),
                                        ),
                                        data: (typePayments) {
                                          return DropDownApp(
                                            items: typePayments,
                                            initialValue: _selectedTypePayment,
                                            onChanged: (newValue) {
                                              modalSetState(() {
                                                _selectedTypePayment = newValue;
                                              });
                                            },
                                            itemToString: (tp) => tp.name,
                                            labelText:
                                                'Seleccionar Tipo de Pago',
                                            prefixIcon: Icons.payment,
                                            focusNode: _paymentFocusNode,
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      const Divider(),

                                      // --- C. LISTA DE PRODUCTOS (UX MEJORADA) ---
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Productos",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "${_itemsForSale.length} Items",
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),

                                      if (_itemsForSale.isEmpty)
                                        const Padding(
                                          padding: EdgeInsets.all(30.0),
                                          child: Center(
                                            child: Text(
                                              "El carrito está vacío",
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        )
                                      else
                                        ..._itemsForSale.asMap().entries.map((
                                          entry,
                                        ) {
                                          final item = entry.value;
                                          return SaleItemCard(
                                            item: item,
                                            onDecrement: () {
                                              modalSetState(() {
                                                if (item.amount > 1) {
                                                  item.amount--;
                                                } else {
                                                  _itemsForSale.removeAt(
                                                    entry.key,
                                                  );
                                                }
                                              });
                                            },
                                            onIncrement: () {
                                              modalSetState(() {
                                                item.amount++;
                                              });
                                            },
                                            onTapAmount: () {
                                              _mostrarDialogoEditarCantidad(
                                                context,
                                                item,
                                                (val) => modalSetState(() {
                                                  item.amount = val;
                                                }),
                                              );
                                            },
                                          );
                                        }).toList(),

                                      // Espacio extra al final para que el teclado o el footer no tapen el último item
                                      const SizedBox(height: 80),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),

            // --- 4. FOOTER FIJO (Siempre visible) ---
            bottomNavigationBar: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cálculo del Total en tiempo real
                    Builder(
                      builder: (ctx) {
                        // Recalculamos aquí para que se actualice al cambiar cantidades
                        double total = _itemsForSale.fold(
                          0,
                          (prev, el) => prev + (el.amount * el.unitCost),
                        );
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total a Pagar:",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "\$${total.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 15),

                    // Botón Confirmar
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ButtonApp(
                            text: "CANCELAR VENTA",
                            type: ButtonType.secondary,
                            icon: Icons.restart_alt_rounded,
                            onPressed: _restartSale,
                          ),

                          const SizedBox(width: 16),
                          ButtonApp(
                            text: "CONFIRMAR VENTA",
                            type: ButtonType.primary,
                            onPressed: () {
                              if (!formKey.currentState!.validate()) {
                                // Focus is handled automatically by Form on error
                                // modalMessengerKey.currentState?.showSnackBar(
                                //   const SnackBar(
                                //     content: Text(
                                //       '⚠️ Por favor, revise los errores.',
                                //     ),
                                //     behavior: SnackBarBehavior.floating,
                                //     backgroundColor: Colors.red,
                                //   ),
                                // );
                                return;
                              }
                              if (_itemsForSale.isEmpty) {
                                modalMessengerKey.currentState?.showSnackBar(
                                  const SnackBar(
                                    content: Text('⚠️ El carrito está vacío.'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }

                              // Ejecutar guardado con confirmación
                              showDialog(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: const Text("Confirmar Venta"),
                                  content: const Text(
                                    "¿Estás seguro de que deseas procesar esta venta?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext),
                                      child: const Text("NO"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(dialogContext);
                                        _saveSale(context);
                                      },
                                      child: const Text("SI"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ), // Close Scaffold
        ); // Close ScaffoldMessenger
      },
    );
  }

  void _restartSale() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Reiniciar Venta"),
        content: const Text(
          "¿Estás seguro de que deseas limpiar todo el carrito y el cliente seleccionado?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("NO"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Cerrar diálogo
              Navigator.pop(context); // Cerrar Modal bottom sheet
              _itemsForSale.clear();
              selectedClient = null;
            },
            child: const Text("SÍ"),
          ),
        ],
      ),
    );
  }

  // Editar Cantidad
  void _mostrarDialogoEditarCantidad(
    BuildContext context,
    SaleItemModel item,
    Function(int) onConfirm,
  ) {
    final TextEditingController cantidadController = TextEditingController();
    cantidadController.text = item.amount.toString();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Modificar Cantidad"),
          content: TextField(
            controller: cantidadController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Nueva cantidad",
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: const Text("Aceptar"),
              onPressed: () {
                final int? nuevaCantidad = int.tryParse(
                  cantidadController.text,
                );
                if (nuevaCantidad != null && nuevaCantidad > 0) {
                  onConfirm(nuevaCantidad);
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

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

  void _saveSale(BuildContext context) async {
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
        unitCost: item.unitCost,
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
