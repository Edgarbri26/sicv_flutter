import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_text_styles.dart';
import 'package:sicv_flutter/models/index.dart';
import 'package:sicv_flutter/models/product/stock_option_model.dart';
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
    isScrollControlled: true, // Permite que ocupe casi toda la pantalla
    backgroundColor: Colors.transparent, // Transparente para ver el borde redondeado
    builder: (BuildContext modalContext) {
      
      // SOLUCIÓN SNACKBAR:
      // Envolvemos todo en un Scaffold. Esto crea un contexto nuevo donde
      // los SnackBars se dibujan ENCIMA del modal y no detrás.
      return Scaffold(
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                      
                      return Column(
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
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: Text(
                              "Detalles de la Venta",
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          const Divider(height: 1),

                          // --- 3. CONTENIDO CON SCROLL (Lista + Buscador) ---
                          Expanded(
                            child: ListView(
                              controller: scrollController, // Vincula el scroll del sheet
                              padding: const EdgeInsets.all(16),
                              children: [
                                
                                // --- A. SECCIÓN CLIENTE ---
                                const Text("Cliente", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Autocomplete<ClientModel>(
                                        optionsBuilder: (TextEditingValue textEditingValue) {
                                          if (textEditingValue.text.isEmpty) {
                                            return const Iterable<ClientModel>.empty();
                                          }
                                          final currentClients = ref.read(clientProvider).value ?? [];
                                          final term = textEditingValue.text.toLowerCase();
                                          return currentClients.where((ClientModel option) {
                                            return option.name.toLowerCase().contains(term) ||
                                                   option.clientCi.toLowerCase().contains(term);
                                          });
                                        },
                                        displayStringForOption: (ClientModel option) =>
                                            "${option.name} (${option.clientCi})",
                                        onSelected: (ClientModel selection) {
                                          modalSetState(() {
                                            selectedClient = selection;
                                          });
                                        },
                                        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                                          // Usamos tu widget personalizado o un TextField estándar
                                          return TextField(
                                            controller: textEditingController,
                                            focusNode: focusNode,
                                            decoration: const InputDecoration(
                                              labelText: 'Buscar Cliente',
                                              prefixIcon: Icon(Icons.search),
                                              border: OutlineInputBorder(),
                                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0)
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    // Botón Nuevo Cliente
                                    IconButton.filled(
                                      icon: const Icon(Icons.person_add),
                                      onPressed: () async {
                                        // Tu lógica para agregar cliente
                                        // (Copiada de tu código original)
                                        final bool? clientWasAdded = await showModalBottomSheet<bool>(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (ctx) => AddClientForm(
                                            clientService: ClientService(),
                                          ),
                                        );

                                        if (clientWasAdded == true) {
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(modalContext).showSnackBar(
                                            const SnackBar(content: Text('Cliente agregado'), backgroundColor: Colors.green),
                                          );
                                          await ref.read(clientProvider.notifier).refresh();
                                          if (!context.mounted) return;
                                          modalSetState(() {
                                            final newClients = ref.read(clientProvider).value ?? [];
                                            if (newClients.isNotEmpty) selectedClient = newClients.last;
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),

                                // Tarjeta de Cliente Seleccionado
                                if (selectedClient != null)
                                  Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.blue),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.check_circle, color: Colors.blue, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "Seleccionado: ${selectedClient!.name}",
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                const SizedBox(height: 20),

                                // --- B. TIPO DE PAGO ---
                                const Text("Método de Pago", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                                typePaymentsState.when(
                                  loading: () => const LinearProgressIndicator(),
                                  error: (e, s) => Text('Error: $e'),
                                  data: (typePayments) {
                                    return DropdownButtonFormField<TypePaymentModel>( // Asumiendo tu modelo
                                      value: _selectedTypePayment,
                                      isExpanded: true,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                      ),
                                      items: typePayments.map((tp) {
                                        return DropdownMenuItem(value: tp, child: Text(tp.name));
                                      }).toList(),
                                      onChanged: (newValue) {
                                        modalSetState(() {
                                          _selectedTypePayment = newValue;
                                        });
                                      },
                                      hint: const Text("Seleccionar..."),
                                    );
                                  },
                                ),

                                const SizedBox(height: 20),
                                const Divider(),

                                // --- C. LISTA DE PRODUCTOS (UX MEJORADA) ---
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Productos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    Text("${_itemsForSale.length} Items", style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                if (_itemsForSale.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(30.0),
                                    child: Center(child: Text("El carrito está vacío", style: TextStyle(color: Colors.grey))),
                                  )
                                else
                                  ..._itemsForSale.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final item = entry.value;
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      elevation: 0,
                                      color: Colors.white, // Fondo blanco para destacar
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(color: Colors.grey.shade300) // Borde sutil
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0), // Un poco más de padding
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start, // Alinear arriba
                                          children: [
                                            
                                            // --- COLUMNA DE INFORMACIÓN ---
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // 1. Nombre del Producto
                                                  Text(
                                                    item.productName!, 
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                                                  ),
                                                  const SizedBox(height: 6),

                                                  // 2. Información del Depósito (Icono + Texto)
                                                  Row(
                                                    children: [
                                                      Icon(Icons.store, size: 14, color: Colors.grey[600]),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        item.depotName ?? "Depósito", 
                                                        style: TextStyle(color: Colors.grey[700], fontSize: 13)
                                                      ),
                                                    ],
                                                  ),

                                                  // 3. Información de Vencimiento (Solo si existe)
                                                  if (item.expirationInfo != null) ...[
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        // Usamos un icono de alerta si es vencimiento, o calendario normal
                                                        Icon(Icons.event, size: 14, color: Colors.orange[800]),
                                                        const SizedBox(width: 4),
                                                        Expanded(
                                                          child: Text(
                                                            item.expirationInfo!, // Ej: "Vence: 2025-10-10"
                                                            style: TextStyle(
                                                              color: Colors.orange[900], 
                                                              fontSize: 12, 
                                                              fontWeight: FontWeight.w500
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                  
                                                  const SizedBox(height: 6),
                                                  // 4. Precio Unitario
                                                  Text(
                                                    "\$${item.unitCost} c/u", 
                                                    style: TextStyle(color: Colors.blue[800], fontSize: 13, fontWeight: FontWeight.bold)
                                                  ),
                                                ],
                                              ),
                                            ),
                                            
                                            // --- COLUMNA DE CONTROLES (+ / -) ---
                                            Column(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[100],
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(Icons.remove, color: Colors.red, size: 20),
                                                        constraints: const BoxConstraints(minWidth: 35, minHeight: 35),
                                                        padding: EdgeInsets.zero,
                                                        onPressed: () {
                                                          modalSetState(() {
                                                            if (item.amount > 1) {
                                                              item.amount--;
                                                            } else {
                                                              _itemsForSale.removeAt(index);
                                                            }
                                                          });
                                                        },
                                                      ),
                                                      InkWell(
                                                        onTap: () => _mostrarDialogoEditarCantidad(context, item, (val) => modalSetState((){ item.amount = val; })),
                                                        child: Container(
                                                          constraints: const BoxConstraints(minWidth: 30),
                                                          alignment: Alignment.center,
                                                          child: Text(
                                                            "${item.amount}", 
                                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                                                          ),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(Icons.add, color: Colors.green, size: 20),
                                                        constraints: const BoxConstraints(minWidth: 35, minHeight: 35),
                                                        padding: EdgeInsets.zero,
                                                        onPressed: () {
                                                          modalSetState(() {
                                                            item.amount++;
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                // Subtotal del item
                                                Text(
                                                  "\$${(item.unitCost * item.amount).toStringAsFixed(2)}",
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  
                                  // Espacio extra al final para que el teclado o el footer no tapen el último item
                                  const SizedBox(height: 80), 
                              ],
                            ),
                          ),
                        ],
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
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -4))],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cálculo del Total en tiempo real
                Builder(builder: (ctx) {
                   // Recalculamos aquí para que se actualice al cambiar cantidades
                   double total = _itemsForSale.fold(0, (prev, el) => prev + (el.amount * el.unitCost));
                   return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total a Pagar:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        Text("\$${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                   );
                }),
                
                const SizedBox(height: 15),
                
                // Botón Confirmar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800], // Tu AppColors.primary
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 2,
                    ),
                    onPressed: () {
                      // Validaciones
                      if (selectedClient == null) {
                        // USAMOS modalContext para que el SnackBar salga ENCIMA del modal
                        ScaffoldMessenger.of(modalContext).showSnackBar(
                          const SnackBar(
                            content: Text('⚠️ Por favor, seleccione un cliente.'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      if (_itemsForSale.isEmpty) {
                        ScaffoldMessenger.of(modalContext).showSnackBar(
                          const SnackBar(content: Text('⚠️ El carrito está vacío.'), backgroundColor: Colors.orange),
                        );
                        return;
                      }
                      
                      // Ejecutar guardado
                      _saveSale();
                    },
                    child: const Text("CONFIRMAR VENTA", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

// -----------------------------------------------------------------------------
// HELPER PARA EDICIÓN MANUAL (Ya lo tenías, solo ajustado mínimamente)
// -----------------------------------------------------------------------------
void _mostrarDialogoEditarCantidad(
    BuildContext context,
    SaleItemModel item, // Cambia SaleItemModel por el nombre real de tu clase si es diferente
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
                final int? nuevaCantidad = int.tryParse(cantidadController.text);
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

Future<void> _onProductAddedToSale(BuildContext context, ProductModel product) async {
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
        child: _AddProductSheetContent(product: product),
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

class _AddProductSheetContent extends StatefulWidget {
  final ProductModel product;
  const _AddProductSheetContent({required this.product});

  @override
  State<_AddProductSheetContent> createState() => _AddProductSheetContentState();
}

class _AddProductSheetContentState extends State<_AddProductSheetContent> {
  final TextEditingController _qtyController = TextEditingController(text: "1");
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int? _selectedDepotId;
  int? _selectedLotId;
  int _maxStock = 0;
  String? _errorMessage; // Para mostrar errores generales sin usar SnackBar

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  void _updateMaxStock(List<StockOptionModel> allStock) {
    if (_selectedDepotId == null) {
      _maxStock = 0;
      return;
    }

    // Filtrar lotes del depósito seleccionado
    final depotItems = allStock.where((i) => i.depotId == _selectedDepotId).toList();

    if (widget.product.perishable) {
      // Si es perecedero, el stock depende del LOTE específico
      if (_selectedLotId != null) {
        final lot = depotItems.firstWhere(
          (i) => i.lotId == _selectedLotId, 
          orElse: () => StockOptionModel(depotId: 0, depotName: '', amount: 0, isLot: false),
        );
        _maxStock = lot.amount;
      } else {
        _maxStock = 0;
      }
    } else {
      // Si NO es perecedero, sumamos todo lo del depósito
      _maxStock = depotItems.fold(0, (sum, item) => sum + item.amount);
    }
    setState(() {});
  }

  void _incrementQty() {
    int current = int.tryParse(_qtyController.text) ?? 0;
    if (current < _maxStock) {
      _qtyController.text = (current + 1).toString();
    }
  }

  void _decrementQty() {
    int current = int.tryParse(_qtyController.text) ?? 0;
    if (current > 1) {
      _qtyController.text = (current - 1).toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    // NOTA: Asumo que usas Riverpod (Consumer). Si no, usa tu lógica de provider normal.
    // Aquí uso un Consumer local para el ejemplo.
    return Consumer(
      builder: (context, ref, _) {
        final stockAsync = ref.watch(productStockDetailProvider(widget.product.id));

        return Container(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- ENCABEZADO ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.product.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text("Precio: \$${widget.product.price}", style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const Divider(),

                // --- CARGA DE DATOS ---
                stockAsync.when(
                  loading: () => const Center(child: LinearProgressIndicator()),
                  error: (e, _) => Text("Error: $e", style: const TextStyle(color: Colors.red)),
                  data: (stockList) {
                    if (stockList.isEmpty) return const Text("Sin stock disponible", style: TextStyle(color: Colors.red));

                    // Mapa de depósitos únicos
                    final uniqueDepots = { for (var e in stockList) e.depotId : e.depotName };
                    
                    // Lista de lotes filtrada (si aplica)
                    final availableLots = _selectedDepotId == null 
                        ? <StockOptionModel>[] 
                        : stockList.where((e) => e.depotId == _selectedDepotId).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        
                        // --- 1. SELECCIÓN DE DEPÓSITO (Estilo CHIPS) ---
                        const Text("Selecciona Depósito:", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8.0,
                          children: uniqueDepots.entries.map((entry) {
                            final isSelected = _selectedDepotId == entry.key;
                            return ChoiceChip(
                              label: Text(entry.value),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedDepotId = entry.key;
                                    _selectedLotId = null; // Reset lote
                                    _errorMessage = null;
                                    _updateMaxStock(stockList);
                                  });
                                }
                              },
                            );
                          }).toList(),
                        ),
                        if (_selectedDepotId == null && _errorMessage != null)
                           const Text("Debes seleccionar un depósito", style: TextStyle(color: Colors.red, fontSize: 12)),

                        const SizedBox(height: 20),

                        // --- 2. SELECCIÓN DE LOTE (Solo si es perecedero) ---
                        if (widget.product.perishable) ...[
                          DropdownButtonFormField<int>(
                            value: _selectedLotId,
                            decoration: const InputDecoration(
                              labelText: "Fecha de Vencimiento / Lote",
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            ),
                            items: availableLots.map((item) {
                              return DropdownMenuItem(
                                value: item.lotId,
                                child: Text(item.displayLabel, style: const TextStyle(fontSize: 14)),
                              );
                            }).toList(),
                            onChanged: _selectedDepotId == null ? null : (val) {
                              setState(() {
                                _selectedLotId = val;
                                _errorMessage = null;
                                _updateMaxStock(stockList);
                              });
                            },
                            validator: (val) => val == null ? 'Requerido' : null,
                          ),
                          const SizedBox(height: 20),
                        ],

                        // --- 3. CANTIDAD (Estilo STEPPER) ---
                        Row(
                          children: [
                            const Text("Cantidad:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const Spacer(),
                            // Botón Menos
                            Container(
                              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                              child: IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: _selectedDepotId == null ? null : _decrementQty,
                              ),
                            ),
                            const SizedBox(width: 15),
                            // Campo de Texto
                            SizedBox(
                              width: 60,
                              child: TextFormField(
                                controller: _qtyController,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                decoration: const InputDecoration(border: InputBorder.none),
                                validator: (val) {
                                  final num = int.tryParse(val ?? '');
                                  if (num == null || num <= 0) return '!';
                                  if (num > _maxStock) return '!'; // Validación visual simple
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 15),
                            // Botón Más
                            Container(
                              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                              child: IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: _selectedDepotId == null ? null : _incrementQty,
                              ),
                            ),
                          ],
                        ),
                        
                        // Texto informativo de Stock
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            _selectedDepotId == null 
                                ? "Selecciona un depósito primero" 
                                : "Stock disponible: $_maxStock",
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: (int.tryParse(_qtyController.text) ?? 0) > _maxStock 
                                  ? Colors.red 
                                  : Colors.grey[600],
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),

                        // Error general en texto rojo (Sustituto del SnackBar)
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(5)),
                              child: Text(_errorMessage!, style: TextStyle(color: Colors.red[800]), textAlign: TextAlign.center),
                            ),
                          ),

                        const SizedBox(height: 20),

                        // --- 4. BOTÓN DE ACCIÓN ---
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800], // Tu color primario
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              if (_selectedDepotId == null) {
                                setState(() => _errorMessage = "Selecciona un depósito");
                                return;
                              }
                              // Validación del Formulario
                              if (!_formKey.currentState!.validate()) {
                                setState(() => _errorMessage = "Verifica la cantidad y el lote");
                                return;
                              }

                              final amount = int.tryParse(_qtyController.text) ?? 0;
                              
                              if (amount > _maxStock) {
                                setState(() => _errorMessage = "La cantidad excede el stock ($_maxStock)");
                                return;
                              }
  
                              // --- NUEVA LÓGICA PARA OBTENER LOS NOMBRES ---
                              String tempDepotName = "Depósito Desconocido";
                              String? tempExpirationInfo;

                              // 1. Buscamos el objeto del depósito seleccionado
                              if (_selectedDepotId != null) {
                                // stockList está disponible porque estamos dentro del .when(data: stockList)
                                final depotItem = stockList.firstWhere(
                                    (e) => e.depotId == _selectedDepotId, 
                                    orElse: () => StockOptionModel(depotId: 0, depotName: '?', amount: 0, isLot: false)
                                );
                                tempDepotName = depotItem.depotName;
                              }

                              // 2. Buscamos la info del lote/vencimiento seleccionado
                              if (_selectedLotId != null) {
                                final lotItem = stockList.firstWhere(
                                    (e) => e.lotId == _selectedLotId,
                                    orElse: () => StockOptionModel(depotId: 0, depotName: '', amount: 0, isLot: false)
                                );
                                // Aquí usamos tu getter displayLabel o formateamos la fecha
                                tempExpirationInfo = lotItem.displayLabel; 
                                // O si prefieres solo la fecha: item.expiration
                              }
                              // ---------------------------------------------

                              final newItem = SaleItemModel(
                                productId: widget.product.id,
                                depotId: _selectedDepotId!,
                                stockLotId: _selectedLotId,
                                unitCost: widget.product.price,
                                amount: amount,
                                productName: widget.product.name,
                                
                                // GUARDAMOS LA INFO VISUAL:
                                depotName: tempDepotName,
                                expirationInfo: tempExpirationInfo,
                              );

                              Navigator.pop(context, newItem);
                            },
                            child: const Text("AGREGAR AL CARRITO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        )
                      ],
                    );
                  }
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}