import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_text_styles.dart';
import 'package:sicv_flutter/models/index.dart';
import 'package:sicv_flutter/providers/auth_provider.dart';
import 'package:sicv_flutter/providers/category_provider.dart';
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
import 'package:sicv_flutter/ui/widgets/detail_product_cart.dart';
import 'package:sicv_flutter/ui/widgets/img_product.dart';
import 'package:sicv_flutter/ui/widgets/product_card.dart';

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
        _buildCategoryFilter(),

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
                          onTap: () => _onProductAddedToSale(
                            context, 
                            product
                          ),
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
    // Cálculos visuales para el stock (Igual que antes)
    final bool isLowStock = product.totalStock <= product.minStock;
    final Color stockColor = isLowStock ? Colors.red : Colors.green;

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Permite que el sheet ocupe más altura si es necesario
      backgroundColor:
          Colors.transparent, // Para que se noten los bordes redondeados
      builder: (BuildContext context) {
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
                // Usamos un Stack pero sin clip excesivo para que la sombra se vea bien si quisieras
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
                        right: 25, // Ajustado por el padding
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade800,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
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
                                      padding: EdgeInsets.only(
                                        bottom: 6,
                                        left: 4,
                                      ),
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
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    0,
                    24,
                    30,
                  ), // Más padding abajo para seguridad en iPhone
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF1F2937,
                      ), // Un color oscuro/negro para acción principal se ve muy pro
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Navegar al detalle...
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
      },
    );
  }

  // Widget para la barra horizontal de categorías
  Widget _buildCategoryFilter() {
    final categoriesState = ref.watch(categoryProvider);

    final selectedCategoryId = ref.watch(saleSelectedCategoryIdProvider);

    return categoriesState.when(
      loading: () => const SizedBox(
        height: 50,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (error, stack) => SizedBox(
        height: 50,
        child: Center(
          child: Text('Error cargando categorías: ${error.toString()}'),
        ),
      ),
      data: (categories) {
        final List<CategoryModel> categoriesWithAll = [
          CategoryModel(
            id: 0,
            name: 'Todos',
            description: 'Todos los productos',
            status: true,
          ),
          ...categories,
        ];

        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categoriesWithAll.length,
            itemBuilder: (context, index) {
              final category = categoriesWithAll[index];
              final bool isSelected = category.id == selectedCategoryId;

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(category.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(saleSelectedCategoryIdProvider.notifier).state =
                          category.id;
                    }
                  },
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  backgroundColor: AppColors.secondary,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void addNewClient() async {
    final bool? clientWasAdded = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext modalContext) {
        return AddClientForm(clientService: ClientService());
      },
    );

    if (clientWasAdded == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cliente agregado correctamente'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void showSaleDetail(BuildContext context) {

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        const double sheetSize = 0.8;

        return Consumer(
          builder: (context, ref, child) {
            final typePaymentsState = ref.watch(typePaymentProvider);
            final clientsState = ref.watch(clientProvider);
            _searchClientController.addListener(_onSearchChanged);

            return StatefulBuilder(
              builder: (BuildContext context, StateSetter modalSetState) {
                double total = _itemsForSale.fold(
                  0,
                  (previousValue, element) =>
                      previousValue + (element.amount * element.unitCost),
                );

                return DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: sheetSize,
                  minChildSize: 0.3,
                  maxChildSize: sheetSize,
                  builder: (context, scrollController) {
                    return Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 5,
                              margin: const EdgeInsets.only(bottom: 15),
                              decoration: BoxDecoration(
                                color: AppColors.border,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              "Detalles de la Venta",
                              textAlign: TextAlign.center,
                              style: AppTextStyles.headlineLarge,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Selección de Cliente y Botón Nuevo
                          Row(
                            children: [
                              Expanded(
                                child: Autocomplete<ClientModel>(
                                  optionsBuilder:
                                      (TextEditingValue textEditingValue) {
                                        if (textEditingValue.text.isEmpty) {
                                          return const Iterable<
                                            ClientModel
                                          >.empty();
                                        }
                                        final currentClients =
                                            ref.read(clientProvider).value ??
                                            [];
                                        return currentClients.where((
                                          ClientModel option,
                                        ) {
                                          final term = textEditingValue.text
                                              .toLowerCase();
                                          return option.name
                                                  .toLowerCase()
                                                  .contains(term) ||
                                              option.clientCi
                                                  .toLowerCase()
                                                  .contains(term);
                                        });
                                      },
                                  displayStringForOption:
                                      (ClientModel option) =>
                                          "${option.name} (${option.clientCi})",
                                  onSelected: (ClientModel selection) {
                                    modalSetState(() {
                                      selectedClient = selection;
                                    });
                                  },
                                  fieldViewBuilder:
                                      (
                                        context,
                                        textEditingController,
                                        focusNode,
                                        onFieldSubmitted,
                                      ) {
                                        return SearchTextFieldApp(
                                          controller: textEditingController,
                                          focusNode: focusNode,
                                          labelText:
                                              'Buscar Cliente (Nombre o CI)',
                                          prefixIcon: Icons.person_search,
                                        );
                                      },
                                ),
                              ),
                              const SizedBox(width: 10),
                              PrimaryButtonApp(
                                text: "Nuevo",
                                onPressed: () async {
                                  // 1. Abrimos el modal directamente AQUÍ
                                  final bool?
                                  clientWasAdded = await showModalBottomSheet<bool>(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: AppColors.primary,
                                    builder: (ctx) => AddClientForm(
                                      // <--- Asegúrate de importar este widget
                                      clientService:
                                          ClientService(), // O tu instancia de servicio
                                    ),
                                  );

                                  // 2. Si se agregó, refrescamos la lista
                                  if (clientWasAdded == true) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Cliente agregado correctamente',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );

                                    // Refrescamos el provider
                                    await ref
                                        .read(clientProvider.notifier)
                                        .refresh();

                                    if (!context.mounted) return;

                                    modalSetState(() {
                                      final newClients =
                                          ref.read(clientProvider).value ?? [];
                                      if (newClients.isNotEmpty) {
                                        selectedClient = newClients.last;
                                      }
                                    });
                                  }
                                },
                              ),
                            ],
                          ),

                          if (selectedClient != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 8.0,
                                bottom: 8.0,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.primary),
                                ),
                                child: Text(
                                  "Cliente: ${selectedClient!.name}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 20),

                          // Tipos de Pago (Riverpod)
                          typePaymentsState.when(
                            loading: () => const CategoryLoadingSkeleton(),
                            error: (error, stack) =>
                                Center(child: Text('Error: $error')),
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
                                labelText: 'Seleccionar Tipo de Pago',
                                prefixIcon: Icons.payment,
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          // Total y Botón Confirmar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total: \$${total.toStringAsFixed(2)}",
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              PrimaryButtonApp(
                                text: "Confirmar",
                                onPressed: () {
                                  if (selectedClient == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Por favor, seleccione un cliente.',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  _saveSale();
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),
                          const Divider(),

                          // Lista de Productos
                          Expanded(
                            child: _itemsForSale.isEmpty
                                ? const Center(
                                    child: Text("No hay artículos agregados"),
                                  )
                                : ListView.builder(
                                    controller:
                                        scrollController, // Importante para DraggableScrollableSheet
                                    itemCount: _itemsForSale.length,
                                    itemBuilder: (context, index) {
                                      final item = _itemsForSale[index];
                                      return DetailProductCart(
                                        item: item,
                                        onTap: () {
                                          _mostrarDialogoEditarCantidad(
                                            context,
                                            item,
                                            (nuevaCantidad) {
                                              // Actualizamos el estado DEL MODAL
                                              modalSetState(() {
                                                item.amount = nuevaCantidad;
                                              });
                                            },
                                          );
                                        },
                                        onDelete: () {
                                          modalSetState(() {
                                            _itemsForSale.removeAt(index);
                                          });
                                        },
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

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
          title: Text("Modificar Cantidad"),
          content: TextField(
            controller: cantidadController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Nueva cantidad",
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text("Confirmar"),
              onPressed: () {
                final int? nuevaCantidad = int.tryParse(
                  cantidadController.text,
                );

                if (nuevaCantidad != null && nuevaCantidad >= 0) {
                  onConfirm(nuevaCantidad);
                  Navigator.of(dialogContext).pop();
                } else {
                  // Opcional: Mostrar un error si el valor no es válido
                  // (ej: usando un SnackBar o moviendo la lógica a un validador)
                }
              },
            ),
          ],
        );
      },
    ).whenComplete(() => cantidadController.clear());
  }

  void _onProductAddedToSale(BuildContext context, ProductModel product) {

    final TextEditingController cantidadController = TextEditingController();
    cantidadController.text = product.quantity.toString();
    List<DepotModel> _depots = [];
    //final List<DepotModel> _depots = ref.read(depotProvider).value ?? [];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Ingresa la cantidad para ${product.name} y selecciona un depósito"),
          content: Column(
            children: [
              TextFieldApp(
                controller: cantidadController,
                keyboardType: TextInputType.number,
                labelText: "Cantidad del producto",
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                DropDownApp(
                  initialValue: null,
                  items: _depots, 
                  onChanged: (newValue) {
                    // Lógica para manejar el cambio de depósito
                  }, 
                  itemToString: (depot) => depot!.name, 
                  labelText: 'Seleccionar Depósito',
                  prefixIcon: Icons.store,
                ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text("Confirmar"),
              onPressed: () {
                final int? nuevaCantidad = int.tryParse(
                  cantidadController.text,
                );
                
                if (nuevaCantidad != null && nuevaCantidad >= 0) {
                  print("product.id: ${product.id}");
                  final saleItem = SaleItemModel(
                    productId: product.id,
                    depotId: 1, // Aquí deberías usar el ID del depósito seleccionado
                    unitCost: product.price,
                    amount: nuevaCantidad,
                    productName: product.name,
                  );

                  _itemsForSale.add(saleItem);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} añadido a la venta.'),
                      duration: Duration(milliseconds: 500),
                    ),
                  );
                  Navigator.of(dialogContext).pop();
                } else {
                  // Opcional: Mostrar un error si el valor no es válido
                  // (ej: usando un SnackBar o moviendo la lógica a un validador)
                }
              },
            ),
          ],
        
        );
      }
    ).whenComplete(() => cantidadController.clear());
  }

  void _saveSale() async {
    // 1. Validaciones PRIMERO
    if (_itemsForSale.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La venta no puede estar vacía. Agrega productos.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, seleccione un cliente.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedTypePayment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, seleccione un tipo de pago.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // --- CORRECCIÓN AQUÍ ---
    // Usamos .value porque authProvider ahora es un AsyncValue
    final user = ref.read(authProvider).value;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No hay sesión de usuario activa.'),
          backgroundColor: Colors.red,
        ),
      );
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
